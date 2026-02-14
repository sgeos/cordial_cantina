defmodule CordialCantina.Integration.WebSocketClientTest do
  use ExUnit.Case, async: true

  alias CordialCantina.Integration.WebSocketClient

  describe "module structure" do
    setup do
      # Ensure module is loaded before checking exports
      {:module, _} = Code.ensure_loaded(WebSocketClient)
      :ok
    end

    test "defines start_link/1" do
      assert function_exported?(WebSocketClient, :start_link, 1)
    end

    test "defines connect/1" do
      assert function_exported?(WebSocketClient, :connect, 1)
    end

    test "defines disconnect/1" do
      assert function_exported?(WebSocketClient, :disconnect, 1)
    end

    test "defines send_message/2" do
      assert function_exported?(WebSocketClient, :send_message, 2)
    end

    test "defines status/1" do
      assert function_exported?(WebSocketClient, :status, 1)
    end
  end

  describe "initialization" do
    test "starts in disconnected state" do
      {:ok, pid} =
        WebSocketClient.start_link(
          url: "wss://example.com/socket",
          topic: "test:topic"
        )

      assert WebSocketClient.status(pid) == :disconnected

      GenServer.stop(pid)
    end

    test "requires url option" do
      Process.flag(:trap_exit, true)

      # start_link will return {:error, _} or the process will exit
      result = WebSocketClient.start_link(topic: "test:topic")

      case result do
        {:error, _} ->
          :ok

        {:ok, pid} ->
          # Should receive exit message due to init failure
          assert_receive {:EXIT, ^pid, _reason}, 1000
      end
    end
  end

  describe "send_message/2" do
    test "returns error when not connected" do
      {:ok, pid} =
        WebSocketClient.start_link(
          url: "wss://example.com/socket",
          topic: "test:topic"
        )

      assert {:error, :not_connected} = WebSocketClient.send_message(pid, "test")

      GenServer.stop(pid)
    end
  end
end
