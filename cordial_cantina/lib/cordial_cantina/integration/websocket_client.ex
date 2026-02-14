defmodule CordialCantina.Integration.WebSocketClient do
  @moduledoc """
  WebSocket client for real-time market data feeds.

  Uses Mint.WebSocket for low-level WebSocket connection management.
  Designed for integration with Birdeye and other real-time data sources.

  ## Architecture

  This module provides a GenServer wrapper around Mint.WebSocket that:
  - Manages connection lifecycle (connect, reconnect, disconnect)
  - Handles WebSocket frames (text, binary, ping/pong)
  - Publishes received data via Phoenix.PubSub
  - Supports automatic reconnection with exponential backoff

  ## Usage

      # Start the client
      {:ok, pid} = WebSocketClient.start_link(
        url: "wss://public-api.birdeye.so/socket/solana",
        name: :birdeye_ws,
        pubsub: CordialCantina.PubSub,
        topic: "market_data:birdeye"
      )

      # Subscribe to data
      Phoenix.PubSub.subscribe(CordialCantina.PubSub, "market_data:birdeye")

      # Receive data
      receive do
        {:websocket_message, data} -> handle_data(data)
      end

  ## State Machine

  ```
  :disconnected -> :connecting -> :connected
        ^                              |
        |______________________________|
              (on error/close)
  ```
  """

  use GenServer

  require Logger

  @type state :: %{
          conn: Mint.HTTP.t() | nil,
          websocket: Mint.WebSocket.t() | nil,
          ref: Mint.Types.request_ref() | nil,
          url: String.t(),
          host: String.t(),
          port: non_neg_integer(),
          path: String.t(),
          status: :disconnected | :connecting | :connected,
          pubsub: module(),
          topic: String.t(),
          reconnect_attempts: non_neg_integer(),
          max_reconnect_attempts: non_neg_integer(),
          base_reconnect_delay: non_neg_integer()
        }

  @default_max_reconnect_attempts 10
  @default_base_reconnect_delay 1000

  # Client API

  @doc """
  Starts the WebSocket client.

  ## Options

  - `:url` - WebSocket URL (required)
  - `:name` - Process name (optional)
  - `:pubsub` - PubSub module for broadcasting messages (default: CordialCantina.PubSub)
  - `:topic` - Topic to broadcast messages to (default: "websocket:default")
  - `:max_reconnect_attempts` - Maximum reconnection attempts (default: 10)
  - `:base_reconnect_delay` - Base delay for exponential backoff in ms (default: 1000)
  """
  def start_link(opts) do
    name = Keyword.get(opts, :name)
    gen_opts = if name, do: [name: name], else: []
    GenServer.start_link(__MODULE__, opts, gen_opts)
  end

  @doc """
  Connects to the WebSocket server.
  """
  def connect(pid) do
    GenServer.call(pid, :connect)
  end

  @doc """
  Disconnects from the WebSocket server.
  """
  def disconnect(pid) do
    GenServer.call(pid, :disconnect)
  end

  @doc """
  Sends a message over the WebSocket connection.
  """
  def send_message(pid, message) when is_binary(message) do
    GenServer.call(pid, {:send, message})
  end

  @doc """
  Returns the current connection status.
  """
  def status(pid) do
    GenServer.call(pid, :status)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    url = Keyword.fetch!(opts, :url)
    uri = URI.parse(url)

    state = %{
      conn: nil,
      websocket: nil,
      ref: nil,
      url: url,
      host: uri.host,
      port: uri.port || default_port(uri.scheme),
      path: uri.path || "/",
      status: :disconnected,
      pubsub: Keyword.get(opts, :pubsub, CordialCantina.PubSub),
      topic: Keyword.get(opts, :topic, "websocket:default"),
      reconnect_attempts: 0,
      max_reconnect_attempts:
        Keyword.get(opts, :max_reconnect_attempts, @default_max_reconnect_attempts),
      base_reconnect_delay:
        Keyword.get(opts, :base_reconnect_delay, @default_base_reconnect_delay)
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:connect, _from, %{status: :disconnected} = state) do
    case do_connect(state) do
      {:ok, new_state} ->
        {:reply, :ok, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:connect, _from, state) do
    {:reply, {:error, :already_connected}, state}
  end

  @impl true
  def handle_call(:disconnect, _from, state) do
    new_state = do_disconnect(state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:send, message}, _from, %{status: :connected} = state) do
    case do_send(state, message) do
      {:ok, new_state} ->
        {:reply, :ok, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:send, _message}, _from, state) do
    {:reply, {:error, :not_connected}, state}
  end

  @impl true
  def handle_call(:status, _from, state) do
    {:reply, state.status, state}
  end

  @impl true
  def handle_info(:reconnect, state) do
    if state.reconnect_attempts < state.max_reconnect_attempts do
      case do_connect(state) do
        {:ok, new_state} ->
          {:noreply, %{new_state | reconnect_attempts: 0}}

        {:error, _reason} ->
          new_state = %{state | reconnect_attempts: state.reconnect_attempts + 1}
          schedule_reconnect(new_state)
          {:noreply, new_state}
      end
    else
      Logger.error("Max reconnection attempts reached")
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(message, state) do
    case Mint.WebSocket.stream(state.conn, message) do
      {:ok, conn, responses} ->
        new_state = %{state | conn: conn}
        handle_responses(responses, new_state)

      {:error, _conn, reason, _responses} ->
        Logger.warning("WebSocket stream error: #{inspect(reason)}")
        schedule_reconnect(state)
        {:noreply, %{state | status: :disconnected, conn: nil, websocket: nil}}

      :unknown ->
        {:noreply, state}
    end
  end

  # Private Functions

  defp default_port("ws"), do: 80
  defp default_port("wss"), do: 443
  defp default_port(_), do: 443

  defp do_connect(state) do
    scheme = if state.port == 443, do: :https, else: :http

    with {:ok, conn} <- Mint.HTTP.connect(scheme, state.host, state.port),
         {:ok, conn, ref} <- Mint.WebSocket.upgrade(scheme, conn, state.path, []) do
      {:ok, %{state | conn: conn, ref: ref, status: :connecting}}
    else
      {:error, reason} ->
        Logger.error("WebSocket connection failed: #{inspect(reason)}")
        {:error, reason}

      {:error, _conn, reason} ->
        Logger.error("WebSocket upgrade failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp do_disconnect(state) do
    if state.conn do
      Mint.HTTP.close(state.conn)
    end

    %{state | conn: nil, websocket: nil, ref: nil, status: :disconnected}
  end

  defp do_send(state, message) do
    frame = {:text, message}

    case Mint.WebSocket.encode(state.websocket, frame) do
      {:ok, websocket, data} ->
        case Mint.WebSocket.stream_request_body(state.conn, state.ref, data) do
          {:ok, conn} ->
            {:ok, %{state | conn: conn, websocket: websocket}}

          {:error, _conn, reason} ->
            {:error, reason}
        end

      {:error, _websocket, reason} ->
        {:error, reason}
    end
  end

  defp handle_responses(responses, state) do
    Enum.reduce(responses, {:noreply, state}, fn response, {_action, acc_state} ->
      handle_response(response, acc_state)
    end)
  end

  defp handle_response({:status, ref, status}, %{ref: ref} = state) do
    Logger.debug("WebSocket status: #{status}")
    {:noreply, state}
  end

  defp handle_response({:headers, ref, headers}, %{ref: ref} = state) do
    Logger.debug("WebSocket headers: #{inspect(headers)}")
    {:noreply, state}
  end

  defp handle_response({:done, ref}, %{ref: ref} = state) do
    case Mint.WebSocket.new(state.conn, ref, state.status, []) do
      {:ok, conn, websocket} ->
        Logger.info("WebSocket connected to #{state.host}")
        {:noreply, %{state | conn: conn, websocket: websocket, status: :connected}}

      {:error, _conn, reason} ->
        Logger.error("WebSocket handshake failed: #{inspect(reason)}")
        {:noreply, %{state | status: :disconnected}}
    end
  end

  defp handle_response({:data, ref, data}, %{ref: ref} = state) do
    case Mint.WebSocket.decode(state.websocket, data) do
      {:ok, websocket, frames} ->
        new_state = %{state | websocket: websocket}
        handle_frames(frames, new_state)

      {:error, _websocket, reason} ->
        Logger.warning("WebSocket decode error: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  defp handle_response(_response, state) do
    {:noreply, state}
  end

  defp handle_frames(frames, state) do
    Enum.each(frames, fn frame ->
      handle_frame(frame, state)
    end)

    {:noreply, state}
  end

  defp handle_frame({:text, text}, state) do
    Phoenix.PubSub.broadcast(state.pubsub, state.topic, {:websocket_message, text})
  end

  defp handle_frame({:binary, binary}, state) do
    Phoenix.PubSub.broadcast(state.pubsub, state.topic, {:websocket_binary, binary})
  end

  defp handle_frame({:ping, data}, state) do
    # Respond to ping with pong
    frame = {:pong, data}

    case Mint.WebSocket.encode(state.websocket, frame) do
      {:ok, _websocket, encoded} ->
        Mint.WebSocket.stream_request_body(state.conn, state.ref, encoded)

      {:error, _websocket, reason} ->
        Logger.warning("Failed to respond to ping: #{inspect(reason)}")
    end
  end

  defp handle_frame({:pong, _data}, _state) do
    Logger.debug("Received pong")
  end

  defp handle_frame({:close, code, reason}, state) do
    Logger.info("WebSocket closed: #{code} - #{reason}")
    schedule_reconnect(state)
  end

  defp handle_frame(frame, _state) do
    Logger.debug("Unknown frame: #{inspect(frame)}")
  end

  defp schedule_reconnect(state) do
    delay = state.base_reconnect_delay * :math.pow(2, state.reconnect_attempts)
    delay = min(trunc(delay), 30_000)
    Process.send_after(self(), :reconnect, delay)
  end
end
