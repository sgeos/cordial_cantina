defmodule CordialCantina.MarketData.OrderBook do
  @moduledoc """
  Ecto schema for order book snapshot data.

  This schema mirrors the Mnesia `:order_book` table for cold storage persistence.
  Per R1: Data rotating out of Mnesia is offloaded to PostgreSQL for historical queries.

  ## Fields

  - `token_pair` - Trading pair identifier (e.g., "SOL/USDC")
  - `timestamp` - UTC timestamp of the snapshot
  - `bids` - List of bid orders as `[%{price: Decimal, quantity: Decimal}, ...]`
  - `asks` - List of ask orders as `[%{price: Decimal, quantity: Decimal}, ...]`
  - `spread` - Bid-ask spread
  - `mid_price` - Mid-market price
  - `source` - Data source identifier (e.g., "birdeye")
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type order :: %{price: Decimal.t(), quantity: Decimal.t()}

  @type t :: %__MODULE__{
          id: integer() | nil,
          token_pair: String.t() | nil,
          timestamp: DateTime.t() | nil,
          bids: [order()] | nil,
          asks: [order()] | nil,
          spread: Decimal.t() | nil,
          mid_price: Decimal.t() | nil,
          source: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "order_books" do
    field(:token_pair, :string)
    field(:timestamp, :utc_datetime_usec)
    field(:bids, {:array, :map})
    field(:asks, {:array, :map})
    field(:spread, :decimal)
    field(:mid_price, :decimal)
    field(:source, :string)

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields ~w(token_pair timestamp bids asks spread mid_price source)a

  @doc """
  Changeset for creating or updating an order book record.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(order_book, attrs) do
    order_book
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
