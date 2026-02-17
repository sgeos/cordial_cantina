defmodule CordialCantina.Integration.BirdeyeWebSocket do
  @moduledoc """
  Birdeye WebSocket client for real-time price feed ingestion.

  Connects to Birdeye WebSocket API and subscribes to price updates
  for configured token addresses. Data is published via PubSub for
  downstream processing by the Broadway pipeline.

  ## Configuration

  Configure in `config/runtime.exs`:

      config :cordial_cantina, CordialCantina.Integration.BirdeyeWebSocket,
        api_key: System.get_env("BIRDEYE_API_KEY"),
        tokens: [
          %{address: "So11111111111111111111111111111111111111112", symbol: "SOL"},
          %{address: "3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh", symbol: "wBTC"}
        ],
        chart_type: "1m"

  ## Architecture

  Per R13 and R19 decisions:
  - WebSocket endpoint: wss://public-api.birdeye.so/socket/solana
  - Authentication via x-api-key query parameter
  - SUBSCRIBE_PRICE for OHLCV data
  - Publishes to "market_data:birdeye" topic
  """

  use GenServer

  require Logger

  alias CordialCantina.Integration.WebSocketClient

  @default_topic "market_data:birdeye"
  @default_chart_type "1m"
  @ws_base_url "wss://public-api.birdeye.so/socket/solana"

  # Well-known token addresses per R16
  @sol_address "So11111111111111111111111111111111111111112"
  @wbtc_portal_address "3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh"

  @type token :: %{address: String.t(), symbol: String.t()}

  @type state :: %{
          ws_pid: pid() | nil,
          api_key: String.t() | nil,
          tokens: [token()],
          chart_type: String.t(),
          topic: String.t(),
          subscribed: boolean(),
          last_prices: %{String.t() => map()}
        }

  # Client API

  @doc """
  Starts the Birdeye WebSocket client.

  ## Options

  - `:api_key` - Birdeye API key (required for production)
  - `:tokens` - List of token maps with :address and :symbol keys
  - `:chart_type` - OHLCV interval (default: "1m")
  - `:topic` - PubSub topic (default: "market_data:birdeye")
  - `:name` - Process name (optional)
  """
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name)
    gen_opts = if name, do: [name: name], else: []
    GenServer.start_link(__MODULE__, opts, gen_opts)
  end

  @doc """
  Connects to Birdeye WebSocket and subscribes to configured tokens.
  """
  def connect(pid) do
    GenServer.call(pid, :connect)
  end

  @doc """
  Disconnects from Birdeye WebSocket.
  """
  def disconnect(pid) do
    GenServer.call(pid, :disconnect)
  end

  @doc """
  Returns the current connection status.
  """
  def status(pid) do
    GenServer.call(pid, :status)
  end

  @doc """
  Returns the last known prices for all subscribed tokens.
  """
  def last_prices(pid) do
    GenServer.call(pid, :last_prices)
  end

  @doc """
  Returns the default SOL token address.
  """
  def sol_address, do: @sol_address

  @doc """
  Returns the default Portal wBTC token address.
  """
  def wbtc_address, do: @wbtc_portal_address

  # Server Callbacks

  @impl true
  def init(opts) do
    config = Application.get_env(:cordial_cantina, __MODULE__, [])

    api_key = Keyword.get(opts, :api_key) || Keyword.get(config, :api_key)

    tokens =
      Keyword.get(opts, :tokens) ||
        Keyword.get(config, :tokens) ||
        default_tokens()

    state = %{
      ws_pid: nil,
      api_key: api_key,
      tokens: tokens,
      chart_type: Keyword.get(opts, :chart_type, @default_chart_type),
      topic: Keyword.get(opts, :topic, @default_topic),
      subscribed: false,
      last_prices: %{}
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:connect, _from, state) do
    case start_websocket(state) do
      {:ok, ws_pid} ->
        # Subscribe to WebSocket messages
        Phoenix.PubSub.subscribe(CordialCantina.PubSub, state.topic)
        {:reply, :ok, %{state | ws_pid: ws_pid}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:disconnect, _from, %{ws_pid: nil} = state) do
    {:reply, :ok, state}
  end

  def handle_call(:disconnect, _from, %{ws_pid: ws_pid} = state) do
    WebSocketClient.disconnect(ws_pid)
    {:reply, :ok, %{state | ws_pid: nil, subscribed: false}}
  end

  @impl true
  def handle_call(:status, _from, state) do
    status =
      cond do
        state.ws_pid == nil -> :disconnected
        state.subscribed -> :subscribed
        true -> :connected
      end

    {:reply, status, state}
  end

  @impl true
  def handle_call(:last_prices, _from, state) do
    {:reply, state.last_prices, state}
  end

  @impl true
  def handle_info({:websocket_message, message}, state) do
    case Jason.decode(message) do
      {:ok, %{"type" => "PRICE_DATA"} = data} ->
        new_state = handle_price_data(data, state)
        {:noreply, new_state}

      {:ok, %{"type" => "CONNECTED"}} ->
        Logger.info("Birdeye WebSocket connected, subscribing to tokens...")
        send_subscriptions(state)
        {:noreply, %{state | subscribed: true}}

      {:ok, %{"type" => type}} ->
        Logger.debug("Birdeye WebSocket message: #{type}")
        {:noreply, state}

      {:error, _} ->
        Logger.warning("Failed to parse WebSocket message: #{inspect(message)}")
        {:noreply, state}
    end
  end

  def handle_info({:websocket_binary, _binary}, state) do
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Private Functions

  defp start_websocket(state) do
    url = build_websocket_url(state.api_key)

    opts = [
      url: url,
      pubsub: CordialCantina.PubSub,
      topic: state.topic
    ]

    case WebSocketClient.start_link(opts) do
      {:ok, pid} ->
        case WebSocketClient.connect(pid) do
          :ok -> {:ok, pid}
          error -> error
        end

      error ->
        error
    end
  end

  defp build_websocket_url(nil) do
    Logger.warning("No Birdeye API key configured, WebSocket may not authenticate")
    @ws_base_url
  end

  defp build_websocket_url(api_key) do
    "#{@ws_base_url}?x-api-key=#{api_key}"
  end

  defp send_subscriptions(%{ws_pid: ws_pid, tokens: tokens, chart_type: chart_type}) do
    Enum.each(tokens, fn token ->
      subscription = %{
        type: "SUBSCRIBE_PRICE",
        data: %{
          queryType: "simple",
          chartType: chart_type,
          address: token.address,
          currency: "usd"
        }
      }

      message = Jason.encode!(subscription)
      WebSocketClient.send_message(ws_pid, message)
      Logger.info("Subscribed to #{token.symbol} (#{token.address})")
    end)
  end

  defp handle_price_data(%{"data" => data}, state) do
    address = data["address"]
    symbol = find_symbol(state.tokens, address)
    timestamp = unix_to_datetime(data["unixTime"])

    price_data = %{
      address: address,
      symbol: symbol,
      open: data["o"],
      high: data["h"],
      low: data["l"],
      close: data["c"],
      volume: data["v"],
      timestamp: timestamp,
      received_at: DateTime.utc_now()
    }

    # Write to Mnesia for hot storage
    write_to_mnesia(price_data, state.chart_type)

    # Emit telemetry event
    :telemetry.execute(
      [:cordial_cantina, :market_data, :price_update],
      %{count: 1},
      %{symbol: symbol, source: "birdeye"}
    )

    # Broadcast to market data topic for LiveView updates
    Phoenix.PubSub.broadcast(
      CordialCantina.PubSub,
      "market_data:price_feed",
      {:price_update, price_data}
    )

    %{state | last_prices: Map.put(state.last_prices, address, price_data)}
  end

  defp unix_to_datetime(nil), do: DateTime.utc_now()

  defp unix_to_datetime(unix_time) when is_integer(unix_time) do
    DateTime.from_unix!(unix_time)
  end

  defp unix_to_datetime(unix_time) when is_float(unix_time) do
    DateTime.from_unix!(trunc(unix_time))
  end

  defp unix_to_datetime(_), do: DateTime.utc_now()

  defp write_to_mnesia(price_data, interval) do
    token_pair = "#{price_data.symbol}/USD"
    timestamp = price_data.timestamp
    key = {token_pair, timestamp}

    record =
      {:price_feed, key, token_pair, timestamp, price_data.open, price_data.high,
       price_data.low, price_data.close, price_data.volume, interval, "birdeye"}

    case :mnesia.transaction(fn -> :mnesia.write(record) end) do
      {:atomic, :ok} ->
        :telemetry.execute(
          [:cordial_cantina, :mnesia, :write],
          %{count: 1},
          %{table: :price_feed}
        )

        :ok

      {:aborted, reason} ->
        Logger.warning("Failed to write to Mnesia: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp find_symbol(tokens, address) do
    case Enum.find(tokens, fn t -> t.address == address end) do
      %{symbol: symbol} -> symbol
      nil -> "UNKNOWN"
    end
  end

  defp default_tokens do
    [
      %{address: @sol_address, symbol: "SOL"},
      %{address: @wbtc_portal_address, symbol: "wBTC"}
    ]
  end
end
