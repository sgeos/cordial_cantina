defmodule CordialCantina.Mnesia.SchemaTest do
  use ExUnit.Case, async: false

  alias CordialCantina.Mnesia.Schema

  describe "table_specs/0" do
    test "returns list of table specifications" do
      specs = Schema.table_specs()

      assert is_list(specs)
      assert length(specs) == 2

      for {name, opts} <- specs do
        assert is_atom(name)
        assert is_list(opts)
        assert Keyword.has_key?(opts, :attributes)
        assert Keyword.has_key?(opts, :type)
        assert Keyword.has_key?(opts, :ram_copies)
      end
    end

    test "includes price_feed table" do
      specs = Schema.table_specs()
      {name, opts} = Enum.find(specs, fn {n, _} -> n == :price_feed end)

      assert name == :price_feed
      assert :key in opts[:attributes]
      assert :token_pair in opts[:attributes]
      assert :timestamp in opts[:attributes]
      assert :open in opts[:attributes]
      assert :high in opts[:attributes]
      assert :low in opts[:attributes]
      assert :close in opts[:attributes]
      assert :volume in opts[:attributes]
      assert opts[:type] == :ordered_set
    end

    test "includes order_book table" do
      specs = Schema.table_specs()
      {name, opts} = Enum.find(specs, fn {n, _} -> n == :order_book end)

      assert name == :order_book
      assert :key in opts[:attributes]
      assert :token_pair in opts[:attributes]
      assert :timestamp in opts[:attributes]
      assert :bids in opts[:attributes]
      assert :asks in opts[:attributes]
      assert opts[:type] == :ordered_set
    end
  end

  describe "table_names/0" do
    test "returns list of table names" do
      names = Schema.table_names()

      assert is_list(names)
      assert :price_feed in names
      assert :order_book in names
    end
  end
end
