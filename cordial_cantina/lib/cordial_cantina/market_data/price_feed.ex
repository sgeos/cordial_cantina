defmodule CordialCantina.MarketData.PriceFeed do
  @moduledoc """
  Ecto schema for OHLCV price feed data.

  This schema mirrors the Mnesia `:price_feed` table for cold storage persistence.
  Per R1: Data rotating out of Mnesia is offloaded to PostgreSQL for historical queries.

  ## Fields

  - `token_pair` - Trading pair identifier (e.g., "SOL/USDC")
  - `timestamp` - UTC timestamp of the candle
  - `open` - Opening price
  - `high` - Highest price in the interval
  - `low` - Lowest price in the interval
  - `close` - Closing price
  - `volume` - Trading volume in the interval
  - `interval` - Candle interval (e.g., "1m", "1h", "1D")
  - `source` - Data source identifier (e.g., "birdeye")
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          token_pair: String.t() | nil,
          timestamp: DateTime.t() | nil,
          open: Decimal.t() | nil,
          high: Decimal.t() | nil,
          low: Decimal.t() | nil,
          close: Decimal.t() | nil,
          volume: Decimal.t() | nil,
          interval: String.t() | nil,
          source: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "price_feeds" do
    field(:token_pair, :string)
    field(:timestamp, :utc_datetime_usec)
    field(:open, :decimal)
    field(:high, :decimal)
    field(:low, :decimal)
    field(:close, :decimal)
    field(:volume, :decimal)
    field(:interval, :string)
    field(:source, :string)

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields ~w(token_pair timestamp open high low close volume interval source)a

  @doc """
  Changeset for creating or updating a price feed record.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(price_feed, attrs) do
    price_feed
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:interval, valid_intervals())
  end

  @doc """
  Returns the list of valid interval values.
  """
  @spec valid_intervals() :: [String.t()]
  def valid_intervals do
    ~w(1m 3m 5m 15m 30m 1H 2H 4H 6H 8H 12H 1D 3D 1W 1M)
  end
end
