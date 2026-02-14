defmodule CordialCantina.MarketData.PriceFeedTest do
  use ExUnit.Case, async: true

  alias CordialCantina.MarketData.PriceFeed

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      attrs = %{
        token_pair: "SOL/USDC",
        timestamp: ~U[2026-02-14 12:00:00.000000Z],
        open: Decimal.new("100.00"),
        high: Decimal.new("105.00"),
        low: Decimal.new("99.00"),
        close: Decimal.new("102.50"),
        volume: Decimal.new("1000000"),
        interval: "1H",
        source: "birdeye"
      }

      changeset = PriceFeed.changeset(%PriceFeed{}, attrs)

      assert changeset.valid?
    end

    test "invalid changeset missing required fields" do
      changeset = PriceFeed.changeset(%PriceFeed{}, %{})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).token_pair
      assert "can't be blank" in errors_on(changeset).timestamp
      assert "can't be blank" in errors_on(changeset).open
    end

    test "invalid changeset with invalid interval" do
      attrs = %{
        token_pair: "SOL/USDC",
        timestamp: ~U[2026-02-14 12:00:00.000000Z],
        open: Decimal.new("100.00"),
        high: Decimal.new("105.00"),
        low: Decimal.new("99.00"),
        close: Decimal.new("102.50"),
        volume: Decimal.new("1000000"),
        interval: "invalid",
        source: "birdeye"
      }

      changeset = PriceFeed.changeset(%PriceFeed{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).interval
    end
  end

  describe "valid_intervals/0" do
    test "returns all valid interval types" do
      intervals = PriceFeed.valid_intervals()

      assert "1m" in intervals
      assert "1H" in intervals
      assert "1D" in intervals
      assert "1W" in intervals
      assert "1M" in intervals
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
