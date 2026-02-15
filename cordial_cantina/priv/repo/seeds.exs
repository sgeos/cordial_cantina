# Script for populating the database with seed data.
#
# Usage:
#   mix run priv/repo/seeds.exs
#
# This script is idempotent and can be run multiple times safely.

alias CordialCantina.Repo
alias CordialCantina.MarketData.{PriceFeed, OrderBook}

IO.puts("Seeding database...")

# Helper to generate sample OHLCV data
defmodule Seeds do
  @moduledoc false

  def generate_price_feeds(token_pair, source, count) do
    now = DateTime.utc_now()

    Enum.map(1..count, fn i ->
      timestamp = DateTime.add(now, -i * 60, :second)
      base_price = Decimal.new("100.00")
      variance = Decimal.new("#{:rand.uniform(10) - 5}")

      open = Decimal.add(base_price, variance)
      high = Decimal.add(open, Decimal.new("#{:rand.uniform(5)}"))
      low = Decimal.sub(open, Decimal.new("#{:rand.uniform(5)}"))
      close = Decimal.add(low, Decimal.new("#{:rand.uniform(10)}"))
      volume = Decimal.new("#{1000 + :rand.uniform(9000)}")

      %{
        token_pair: token_pair,
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
        interval: "1m",
        source: source,
        inserted_at: now,
        updated_at: now
      }
    end)
  end

  def generate_order_book(token_pair, source) do
    now = DateTime.utc_now()
    mid_price = Decimal.new("100.50")

    bids =
      Enum.map(1..5, fn i ->
        %{
          "price" => Decimal.to_string(Decimal.sub(mid_price, Decimal.new("#{i * 0.1}"))),
          "quantity" => Decimal.to_string(Decimal.new("#{100 + :rand.uniform(400)}"))
        }
      end)

    asks =
      Enum.map(1..5, fn i ->
        %{
          "price" => Decimal.to_string(Decimal.add(mid_price, Decimal.new("#{i * 0.1}"))),
          "quantity" => Decimal.to_string(Decimal.new("#{100 + :rand.uniform(400)}"))
        }
      end)

    %{
      token_pair: token_pair,
      timestamp: now,
      bids: bids,
      asks: asks,
      spread: Decimal.new("0.20"),
      mid_price: mid_price,
      source: source,
      inserted_at: now,
      updated_at: now
    }
  end
end

# Seed price feed data for SOL/USDC
sol_usdc_feeds = Seeds.generate_price_feeds("SOL/USDC", "birdeye", 10)

Enum.each(sol_usdc_feeds, fn attrs ->
  case Repo.get_by(PriceFeed, token_pair: attrs.token_pair, timestamp: attrs.timestamp) do
    nil ->
      %PriceFeed{}
      |> PriceFeed.changeset(attrs)
      |> Repo.insert!()

    _existing ->
      :ok
  end
end)

IO.puts("  Seeded #{length(sol_usdc_feeds)} SOL/USDC price feed records")

# Seed price feed data for BTC/USDC
btc_usdc_feeds = Seeds.generate_price_feeds("BTC/USDC", "birdeye", 10)

Enum.each(btc_usdc_feeds, fn attrs ->
  case Repo.get_by(PriceFeed, token_pair: attrs.token_pair, timestamp: attrs.timestamp) do
    nil ->
      %PriceFeed{}
      |> PriceFeed.changeset(attrs)
      |> Repo.insert!()

    _existing ->
      :ok
  end
end)

IO.puts("  Seeded #{length(btc_usdc_feeds)} BTC/USDC price feed records")

# Seed order book snapshot for SOL/USDC
sol_order_book = Seeds.generate_order_book("SOL/USDC", "birdeye")

case Repo.get_by(OrderBook, token_pair: sol_order_book.token_pair) do
  nil ->
    %OrderBook{}
    |> OrderBook.changeset(sol_order_book)
    |> Repo.insert!()

    IO.puts("  Seeded SOL/USDC order book snapshot")

  _existing ->
    IO.puts("  SOL/USDC order book already exists, skipping")
end

# Seed order book snapshot for BTC/USDC
btc_order_book = Seeds.generate_order_book("BTC/USDC", "birdeye")

case Repo.get_by(OrderBook, token_pair: btc_order_book.token_pair) do
  nil ->
    %OrderBook{}
    |> OrderBook.changeset(btc_order_book)
    |> Repo.insert!()

    IO.puts("  Seeded BTC/USDC order book snapshot")

  _existing ->
    IO.puts("  BTC/USDC order book already exists, skipping")
end

IO.puts("Database seeding complete!")
