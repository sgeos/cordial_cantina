defmodule CordialCantina.Mnesia.Schema do
  @moduledoc """
  Mnesia table definitions for market data.

  Per R8 decision: Schema is defined iteratively. Tables are added as
  features require them.

  Per R1 decision: All tables use `ram_copies` only. Data is ephemeral
  and PostgreSQL provides durable cold storage.

  ## Tables

  - `:price_feed` - OHLCV price data from market feeds
  - `:order_book` - Order book snapshots

  ## Key Design

  Tables use composite keys for efficient time-range queries:
  - Primary key: `{token_pair, timestamp}`
  - Secondary index: `timestamp` for cross-pair queries
  """

  require Logger

  @doc """
  Returns the list of table specifications for V0.2.

  Each specification is a tuple: `{table_name, options}`
  """
  @spec table_specs() :: [{atom(), keyword()}]
  def table_specs do
    [
      {:price_feed, price_feed_opts()},
      {:order_book, order_book_opts()}
    ]
  end

  @doc """
  Returns table names as a list.
  """
  @spec table_names() :: [atom()]
  def table_names do
    Enum.map(table_specs(), fn {name, _opts} -> name end)
  end

  @doc """
  Creates all tables defined in `table_specs/0`.

  Returns `:ok` if all tables are created successfully.
  Returns `{:error, reason}` on first failure.
  """
  @spec create_tables() :: :ok | {:error, term()}
  def create_tables do
    Enum.reduce_while(table_specs(), :ok, fn {name, opts}, _acc ->
      case create_table(name, opts) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, {name, reason}}}
      end
    end)
  end

  @doc """
  Creates a single table with the given options.
  """
  @spec create_table(atom(), keyword()) :: :ok | {:error, term()}
  def create_table(name, opts) do
    case :mnesia.create_table(name, opts) do
      {:atomic, :ok} ->
        Logger.info("Created Mnesia table: #{name}")
        :ok

      {:aborted, {:already_exists, ^name}} ->
        Logger.debug("Mnesia table already exists: #{name}")
        :ok

      {:aborted, reason} ->
        Logger.error("Failed to create Mnesia table #{name}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Table Specifications

  defp price_feed_opts do
    [
      # Attributes: composite key + OHLCV data
      attributes: [
        :key,
        :token_pair,
        :timestamp,
        :open,
        :high,
        :low,
        :close,
        :volume,
        :interval,
        :source
      ],
      # Ordered set for efficient range queries
      type: :ordered_set,
      # RAM only per R1 decision
      ram_copies: [node()],
      # Index on timestamp for cross-pair queries
      index: [:timestamp]
    ]
  end

  defp order_book_opts do
    [
      # Attributes: composite key + order book data
      attributes: [
        :key,
        :token_pair,
        :timestamp,
        :bids,
        :asks,
        :spread,
        :mid_price,
        :source
      ],
      # Ordered set for efficient range queries
      type: :ordered_set,
      # RAM only per R1 decision
      ram_copies: [node()],
      # Index on timestamp for cross-pair queries
      index: [:timestamp]
    ]
  end
end
