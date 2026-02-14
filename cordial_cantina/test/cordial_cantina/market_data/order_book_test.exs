defmodule CordialCantina.MarketData.OrderBookTest do
  use ExUnit.Case, async: true

  alias CordialCantina.MarketData.OrderBook

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      attrs = %{
        token_pair: "SOL/USDC",
        timestamp: ~U[2026-02-14 12:00:00.000000Z],
        bids: [
          %{price: Decimal.new("100.00"), quantity: Decimal.new("50")},
          %{price: Decimal.new("99.50"), quantity: Decimal.new("100")}
        ],
        asks: [
          %{price: Decimal.new("100.10"), quantity: Decimal.new("75")},
          %{price: Decimal.new("100.50"), quantity: Decimal.new("200")}
        ],
        spread: Decimal.new("0.10"),
        mid_price: Decimal.new("100.05"),
        source: "birdeye"
      }

      changeset = OrderBook.changeset(%OrderBook{}, attrs)

      assert changeset.valid?
    end

    test "invalid changeset missing required fields" do
      changeset = OrderBook.changeset(%OrderBook{}, %{})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).token_pair
      assert "can't be blank" in errors_on(changeset).timestamp
      assert "can't be blank" in errors_on(changeset).bids
      assert "can't be blank" in errors_on(changeset).asks
      assert "can't be blank" in errors_on(changeset).spread
      assert "can't be blank" in errors_on(changeset).mid_price
      assert "can't be blank" in errors_on(changeset).source
    end

    test "valid changeset with empty order lists" do
      attrs = %{
        token_pair: "SOL/USDC",
        timestamp: ~U[2026-02-14 12:00:00.000000Z],
        bids: [],
        asks: [],
        spread: Decimal.new("0"),
        mid_price: Decimal.new("0"),
        source: "birdeye"
      }

      changeset = OrderBook.changeset(%OrderBook{}, attrs)

      assert changeset.valid?
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
