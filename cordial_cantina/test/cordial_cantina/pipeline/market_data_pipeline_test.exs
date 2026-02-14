defmodule CordialCantina.Pipeline.MarketDataPipelineTest do
  use ExUnit.Case, async: false

  alias CordialCantina.Pipeline.MarketDataPipeline

  describe "pipeline configuration" do
    test "module uses Broadway" do
      assert {:module, MarketDataPipeline} = Code.ensure_loaded(MarketDataPipeline)

      # Check that it implements Broadway behaviour
      behaviours =
        MarketDataPipeline.__info__(:attributes)
        |> Keyword.get(:behaviour, [])

      assert Broadway in behaviours
    end

    test "module defines start_link/1" do
      assert function_exported?(MarketDataPipeline, :start_link, 1)
    end
  end

  describe "message processing" do
    test "processes a simple message" do
      # Start a fresh pipeline with a unique name for this test
      pipeline_name = :"market_data_pipeline_test_#{:erlang.unique_integer()}"

      {:ok, pid} = start_test_pipeline(pipeline_name)

      ref =
        Broadway.test_message(
          pipeline_name,
          %{type: :price_feed, token_pair: "SOL/USDC", price: 100.0}
        )

      assert_receive {:ack, ^ref, [_successful], []}, 1000

      # Cleanup
      GenServer.stop(pid)
    end

    test "processes batch of messages" do
      # Start a fresh pipeline with a unique name for this test
      pipeline_name = :"market_data_pipeline_test_batch_#{:erlang.unique_integer()}"

      {:ok, pid} = start_test_pipeline(pipeline_name)

      messages =
        for i <- 1..5 do
          %{type: :price_feed, token_pair: "SOL/USDC", price: 100.0 + i}
        end

      refs =
        Enum.map(messages, fn msg ->
          Broadway.test_message(pipeline_name, msg)
        end)

      for ref <- refs do
        assert_receive {:ack, ^ref, [_successful], []}, 2000
      end

      # Cleanup
      GenServer.stop(pid)
    end
  end

  # Helper to start a test pipeline with a unique name
  defp start_test_pipeline(name) do
    Broadway.start_link(MarketDataPipeline,
      name: name,
      producer: [
        module: {Broadway.DummyProducer, []},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        default: [batch_size: 10, batch_timeout: 100, concurrency: 1]
      ],
      context: []
    )
  end
end
