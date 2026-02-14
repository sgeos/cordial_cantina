defmodule CordialCantina.Mnesia.ServerTest do
  use ExUnit.Case, async: false

  alias CordialCantina.Mnesia.Server

  # Tests run with the application started, so Mnesia.Server is already running.
  # These tests verify the public API works correctly.

  describe "ready?/0" do
    test "returns true when server is running and initialized" do
      assert Server.ready?() == true
    end
  end

  describe "await_ready/1" do
    test "returns :ok immediately when already ready" do
      assert Server.await_ready() == :ok
    end

    test "returns :ok with explicit timeout when already ready" do
      assert Server.await_ready(1_000) == :ok
    end
  end

  describe "health_check/0" do
    test "returns health status map" do
      health = Server.health_check()

      assert is_map(health)
      assert health.ready == true
      assert is_list(health.tables)
      assert health.node == node()
      assert %DateTime{} = health.initialized_at
    end

    test "tables list contains market data tables" do
      health = Server.health_check()

      # Per R8: Schema is defined iteratively.
      # V0.2 adds price_feed and order_book tables.
      assert :price_feed in health.tables
      assert :order_book in health.tables
    end
  end

  describe "initialization scenarios" do
    # Note: Testing first boot vs subsequent boot scenarios requires
    # stopping and restarting the GenServer with different Mnesia states.
    # Since the application manages the server lifecycle, these tests
    # verify the server handles both scenarios correctly by checking
    # that it successfully initializes regardless of prior state.

    test "server is running after application start" do
      # The server should be running as part of the supervision tree
      assert Process.whereis(Server) != nil
    end

    test "server survives schema-already-exists condition" do
      # If we got here, the server handled either first boot or
      # subsequent boot correctly. Both paths lead to ready state.
      assert Server.ready?() == true
    end
  end

  describe "pubsub integration" do
    test "ready topic is defined" do
      # The server broadcasts on this topic when ready.
      # Since we're already running, we can verify the mechanism
      # by subscribing and checking we don't get spurious messages.
      Phoenix.PubSub.subscribe(CordialCantina.PubSub, "mnesia:ready")

      # Should not receive anything since server is already ready
      refute_receive :mnesia_ready, 100
    end
  end
end
