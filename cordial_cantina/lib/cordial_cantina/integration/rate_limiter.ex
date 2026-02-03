defmodule CordialCantina.Integration.RateLimiter do
  @moduledoc """
  Rate limiter for external API calls.

  This GenServer manages rate limiting for external API integrations,
  ensuring we stay within rate limits by spacing out requests.

  ## Design

  For APIs with rate limits like 60 requests/minute, this module:
  1. Tracks the last request time
  2. Enforces minimum intervals between requests
  3. Supports multiple endpoints cycling (round-robin)

  ## Usage

      # Start the rate limiter (usually via supervision tree)
      {:ok, pid} = RateLimiter.start_link(name: :birdeye_limiter, interval_ms: 1100)

      # Acquire permission before making request
      :ok = RateLimiter.acquire(:birdeye_limiter)

      # Make your API call
      result = make_api_call()

  ## Round-Robin Polling

  For polling multiple endpoints within a rate limit:

      # Register endpoints for round-robin
      RateLimiter.register_endpoint(:birdeye_limiter, :sol_usdc)
      RateLimiter.register_endpoint(:birdeye_limiter, :ray_usdc)
      RateLimiter.register_endpoint(:birdeye_limiter, :bonk_usdc)

      # Get next endpoint to poll
      {:ok, endpoint} = RateLimiter.next_endpoint(:birdeye_limiter)
  """

  use GenServer

  require Logger

  @default_interval_ms 1_100

  defstruct [
    :interval_ms,
    :last_request_at,
    :endpoints,
    :current_index
  ]

  # Client API

  @doc """
  Starts the rate limiter.

  ## Options

  - `:name` - Process name (required)
  - `:interval_ms` - Minimum milliseconds between requests (default: #{@default_interval_ms})
  """
  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Acquires permission to make a request.

  Blocks until the rate limit allows a new request.
  Returns `:ok` when ready to proceed.
  """
  @spec acquire(GenServer.server()) :: :ok
  def acquire(server) do
    GenServer.call(server, :acquire, :infinity)
  end

  @doc """
  Acquires permission with a timeout.

  Returns `:ok` if acquired, `{:error, :timeout}` if timeout expires.
  """
  @spec acquire(GenServer.server(), timeout()) :: :ok | {:error, :timeout}
  def acquire(server, timeout) do
    try do
      GenServer.call(server, :acquire, timeout)
    catch
      :exit, {:timeout, _} -> {:error, :timeout}
    end
  end

  @doc """
  Registers an endpoint for round-robin polling.
  """
  @spec register_endpoint(GenServer.server(), term()) :: :ok
  def register_endpoint(server, endpoint) do
    GenServer.call(server, {:register_endpoint, endpoint})
  end

  @doc """
  Gets the next endpoint in the round-robin rotation.

  Also acquires a rate limit slot.
  """
  @spec next_endpoint(GenServer.server()) :: {:ok, term()} | {:error, :no_endpoints}
  def next_endpoint(server) do
    GenServer.call(server, :next_endpoint, :infinity)
  end

  @doc """
  Returns the current state for debugging.
  """
  @spec status(GenServer.server()) :: map()
  def status(server) do
    GenServer.call(server, :status)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    interval_ms = Keyword.get(opts, :interval_ms, @default_interval_ms)

    state = %__MODULE__{
      interval_ms: interval_ms,
      last_request_at: nil,
      endpoints: [],
      current_index: 0
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:acquire, _from, state) do
    state = wait_for_rate_limit(state)
    new_state = %{state | last_request_at: System.monotonic_time(:millisecond)}
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:register_endpoint, endpoint}, _from, state) do
    new_endpoints = state.endpoints ++ [endpoint]
    {:reply, :ok, %{state | endpoints: new_endpoints}}
  end

  @impl true
  def handle_call(:next_endpoint, _from, state) do
    case state.endpoints do
      [] ->
        {:reply, {:error, :no_endpoints}, state}

      endpoints ->
        state = wait_for_rate_limit(state)
        endpoint = Enum.at(endpoints, state.current_index)
        next_index = rem(state.current_index + 1, length(endpoints))

        new_state = %{
          state
          | last_request_at: System.monotonic_time(:millisecond),
            current_index: next_index
        }

        {:reply, {:ok, endpoint}, new_state}
    end
  end

  @impl true
  def handle_call(:status, _from, state) do
    status = %{
      interval_ms: state.interval_ms,
      endpoints: state.endpoints,
      current_index: state.current_index,
      last_request_ms_ago: time_since_last_request(state)
    }

    {:reply, status, state}
  end

  # Private Functions

  defp wait_for_rate_limit(%{last_request_at: nil} = state), do: state

  defp wait_for_rate_limit(state) do
    elapsed = time_since_last_request(state)
    wait_time = state.interval_ms - elapsed

    if wait_time > 0 do
      Process.sleep(wait_time)
    end

    state
  end

  defp time_since_last_request(%{last_request_at: nil}), do: nil

  defp time_since_last_request(state) do
    System.monotonic_time(:millisecond) - state.last_request_at
  end
end
