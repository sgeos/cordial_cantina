defmodule CordialCantina.Repo.Migrations.CreateMarketDataTables do
  @moduledoc """
  Creates PostgreSQL tables for market data persistence.

  Per R1 decision: PostgreSQL provides durable cold storage for historical data.
  These tables mirror the Mnesia schema defined in `CordialCantina.Mnesia.Schema`.
  """

  use Ecto.Migration

  def change do
    # Price feeds table for OHLCV data
    create table(:price_feeds) do
      add :token_pair, :string, null: false
      add :timestamp, :utc_datetime_usec, null: false
      add :open, :decimal, null: false
      add :high, :decimal, null: false
      add :low, :decimal, null: false
      add :close, :decimal, null: false
      add :volume, :decimal, null: false
      add :interval, :string, null: false
      add :source, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Primary index on datetime for time-series queries (per R1)
    create index(:price_feeds, [:timestamp])

    # Composite index for pair-specific time range queries
    create index(:price_feeds, [:token_pair, :timestamp])

    # Unique constraint to prevent duplicate data
    create unique_index(:price_feeds, [:token_pair, :timestamp, :interval, :source])

    # Order books table for order book snapshots
    create table(:order_books) do
      add :token_pair, :string, null: false
      add :timestamp, :utc_datetime_usec, null: false
      add :bids, {:array, :map}, null: false, default: []
      add :asks, {:array, :map}, null: false, default: []
      add :spread, :decimal, null: false
      add :mid_price, :decimal, null: false
      add :source, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    # Primary index on datetime for time-series queries (per R1)
    create index(:order_books, [:timestamp])

    # Composite index for pair-specific time range queries
    create index(:order_books, [:token_pair, :timestamp])

    # Unique constraint to prevent duplicate data
    create unique_index(:order_books, [:token_pair, :timestamp, :source])
  end
end
