defmodule CordialCantina.Pipeline.MarketDataPipeline do
  @moduledoc """
  Broadway pipeline for high-throughput market data ingestion.

  Per R10 decision: Broadway provides message processing with built-in
  back-pressure, batching, and graceful shutdown.

  This pipeline processes market data from external sources (e.g., Birdeye WebSocket)
  and writes to Mnesia for hot storage. Data is later offloaded to PostgreSQL.

  ## Architecture

  ```
  Producer (WebSocket/API) → Processor → Batcher → Mnesia
                                                  ↓
                                              PostgreSQL
  ```

  ## Configuration

  The pipeline is configured via application config:

      config :cordial_cantina, CordialCantina.Pipeline.MarketDataPipeline,
        concurrency: 4,
        batch_size: 100,
        batch_timeout: 1000

  ## Usage

  The pipeline is started as part of the supervision tree.
  To manually start for testing:

      {:ok, pid} = CordialCantina.Pipeline.MarketDataPipeline.start_link([])

  To send test messages:

      Broadway.test_message(CordialCantina.Pipeline.MarketDataPipeline, message)
  """

  use Broadway

  require Logger

  alias Broadway.Message

  @default_concurrency 4
  @default_batch_size 100
  @default_batch_timeout 1000

  def start_link(opts) do
    config = Application.get_env(:cordial_cantina, __MODULE__, [])

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Broadway.DummyProducer, []},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: Keyword.get(config, :concurrency, @default_concurrency)
        ]
      ],
      batchers: [
        default: [
          batch_size: Keyword.get(config, :batch_size, @default_batch_size),
          batch_timeout: Keyword.get(config, :batch_timeout, @default_batch_timeout),
          concurrency: 1
        ]
      ],
      context: opts
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    Logger.debug("Processing market data message: #{inspect(message.data)}")

    message
    |> Message.update_data(&process_data/1)
  end

  @impl true
  def handle_batch(_batcher, messages, _batch_info, _context) do
    Logger.debug("Processing batch of #{length(messages)} messages")

    # Process batch and write to storage
    Enum.each(messages, fn message ->
      write_to_mnesia(message.data)
    end)

    messages
  end

  @impl true
  def handle_failed(messages, _context) do
    Logger.warning("Failed to process #{length(messages)} messages")

    Enum.map(messages, fn message ->
      Logger.warning(
        "Failed message: #{inspect(message.data)}, reason: #{inspect(message.status)}"
      )

      message
    end)
  end

  # Private functions

  defp process_data(data) when is_map(data) do
    # Validate and transform market data
    # This is a placeholder - actual implementation depends on data format
    data
    |> Map.put(:processed_at, DateTime.utc_now())
  end

  defp process_data(data), do: data

  defp write_to_mnesia(data) do
    # Placeholder for Mnesia write
    # Actual implementation will use CordialCantina.Mnesia.Schema
    Logger.debug("Writing to Mnesia: #{inspect(data)}")
    :ok
  end
end
