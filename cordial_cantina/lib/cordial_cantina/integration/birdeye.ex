defmodule CordialCantina.Integration.Birdeye do
  @moduledoc """
  Birdeye API integration for fetching market data.

  This module provides functions for fetching OHLCV (Open, High, Low, Close, Volume)
  data from the Birdeye API.

  ## Configuration

  Set the API key via environment variable:

      BIRDEYE_API_KEY=your_api_key

  Or in config:

      config :cordial_cantina, :birdeye_api_key, "your_api_key"

  ## Rate Limiting

  The free tier is limited to approximately 60 requests per minute.
  This module implements rate limiting to stay within limits.

  ## Usage

      # Fetch OHLCV data for SOL
      {:ok, data} = CordialCantina.Integration.Birdeye.fetch_ohlcv(
        "So11111111111111111111111111111111111111112",
        "15m",
        ~U[2024-01-01 00:00:00Z],
        ~U[2024-01-01 01:00:00Z]
      )

  ## Error Handling

  All functions return `{:ok, result}` or `{:error, reason}` tuples.
  Common errors include:
  - `{:error, :rate_limited}` - Too many requests
  - `{:error, :unauthorized}` - Invalid or missing API key
  - `{:error, {:http_error, status, body}}` - HTTP error response
  """

  require Logger

  @base_url "https://public-api.birdeye.so"
  @default_chain "solana"
  @default_currency "usd"

  # Rate limit: slightly under 60/min to be safe (1 request per 1.1 seconds)
  @rate_limit_ms 1_100

  @valid_intervals ~w(1m 3m 5m 15m 30m 1H 2H 4H 6H 8H 12H 1D 3D 1W 1M)

  @type ohlcv_item :: %{
          open: float(),
          high: float(),
          low: float(),
          close: float(),
          volume: float(),
          unix_time: integer(),
          address: String.t(),
          interval: String.t(),
          currency: String.t()
        }

  @type error_reason ::
          :rate_limited
          | :unauthorized
          | :not_found
          | :api_key_missing
          | {:http_error, integer(), any()}
          | {:request_failed, any()}

  @doc """
  Fetches OHLCV data for a token.

  ## Parameters

  - `address` - Token contract address
  - `interval` - Timeframe: #{Enum.join(@valid_intervals, ", ")}
  - `time_from` - Start time (DateTime or Unix timestamp)
  - `time_to` - End time (DateTime or Unix timestamp)
  - `opts` - Optional parameters:
    - `:chain` - Blockchain (default: "solana")
    - `:currency` - "usd" or "native" (default: "usd")
    - `:api_key` - Override API key from config

  ## Returns

  - `{:ok, [ohlcv_item]}` - List of OHLCV data points
  - `{:error, reason}` - Error tuple
  """
  @spec fetch_ohlcv(
          String.t(),
          String.t(),
          DateTime.t() | integer(),
          DateTime.t() | integer(),
          keyword()
        ) ::
          {:ok, [ohlcv_item()]} | {:error, error_reason()}
  def fetch_ohlcv(address, interval, time_from, time_to, opts \\ []) do
    with :ok <- validate_interval(interval),
         {:ok, api_key} <- get_api_key(opts),
         time_from_unix <- to_unix(time_from),
         time_to_unix <- to_unix(time_to) do
      chain = Keyword.get(opts, :chain, @default_chain)
      currency = Keyword.get(opts, :currency, @default_currency)

      query_params = %{
        "address" => address,
        "type" => interval,
        "time_from" => time_from_unix,
        "time_to" => time_to_unix,
        "currency" => currency
      }

      headers = [
        {"x-chain", chain},
        {"X-API-KEY", api_key}
      ]

      do_request("/defi/ohlcv", query_params, headers)
    end
  end

  @doc """
  Returns the configured rate limit interval in milliseconds.
  """
  @spec rate_limit_ms() :: integer()
  def rate_limit_ms, do: @rate_limit_ms

  @doc """
  Returns the list of valid OHLCV intervals.
  """
  @spec valid_intervals() :: [String.t()]
  def valid_intervals, do: @valid_intervals

  # Private Functions

  defp do_request(path, query_params, headers) do
    url = build_url(path, query_params)

    case Req.get(url, headers: headers, retry: false) do
      {:ok, %{status: 200, body: body}} ->
        parse_ohlcv_response(body)

      {:ok, %{status: 429}} ->
        Logger.warning("Birdeye API rate limited")
        {:error, :rate_limited}

      {:ok, %{status: 401}} ->
        Logger.error("Birdeye API unauthorized - check API key")
        {:error, :unauthorized}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Birdeye API error: status=#{status}")
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        Logger.error("Birdeye API request failed: #{inspect(reason)}")
        {:error, {:request_failed, reason}}
    end
  end

  defp build_url(path, query_params) do
    query_string = URI.encode_query(query_params)
    "#{@base_url}#{path}?#{query_string}"
  end

  defp parse_ohlcv_response(%{"success" => true, "data" => %{"items" => items}}) do
    ohlcv_data =
      Enum.map(items, fn item ->
        %{
          open: item["o"],
          high: item["h"],
          low: item["l"],
          close: item["c"],
          volume: item["v"],
          unix_time: item["unixTime"],
          address: item["address"],
          interval: item["type"],
          currency: item["currency"]
        }
      end)

    {:ok, ohlcv_data}
  end

  defp parse_ohlcv_response(%{"success" => false} = response) do
    {:error, {:api_error, response}}
  end

  defp parse_ohlcv_response(response) do
    {:error, {:unexpected_response, response}}
  end

  defp validate_interval(interval) when interval in @valid_intervals, do: :ok

  defp validate_interval(interval) do
    {:error, {:invalid_interval, interval, @valid_intervals}}
  end

  defp get_api_key(opts) do
    case Keyword.get(opts, :api_key) || Application.get_env(:cordial_cantina, :birdeye_api_key) do
      nil -> {:error, :api_key_missing}
      key -> {:ok, key}
    end
  end

  defp to_unix(%DateTime{} = dt), do: DateTime.to_unix(dt)
  defp to_unix(unix) when is_integer(unix), do: unix
end
