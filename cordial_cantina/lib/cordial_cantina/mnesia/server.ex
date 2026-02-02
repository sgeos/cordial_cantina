defmodule CordialCantina.Mnesia.Server do
  @moduledoc """
  GenServer responsible for Mnesia initialization and schema management.

  This server handles:
  - Schema initialization on first boot
  - Schema joining on subsequent boots
  - Health check queries for readiness probes
  - Broadcasting ready status to dependent processes

  ## Usage

  Dependent processes can wait for Mnesia readiness using:

      CordialCantina.Mnesia.Server.await_ready()

  Or check status without blocking:

      CordialCantina.Mnesia.Server.ready?()

  ## Implementation Notes

  Per R1 decision: Mnesia uses `ram_copies` only. Data is ephemeral and
  PostgreSQL provides durable cold storage.

  Per R2 decision: GenServer provides supervision integration, state
  management, and health check capabilities.

  Per R8 decision: Schema is defined iteratively. Initial tables are
  minimal and expand as features require.
  """

  use GenServer

  require Logger

  @ready_topic "mnesia:ready"
  @await_timeout 30_000

  # Client API

  @doc """
  Starts the Mnesia server.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns true if Mnesia is initialized and ready.
  """
  @spec ready?() :: boolean()
  def ready? do
    GenServer.call(__MODULE__, :ready?)
  catch
    :exit, _ -> false
  end

  @doc """
  Blocks until Mnesia is ready or timeout expires.

  Returns `:ok` if ready, `{:error, :timeout}` if timeout expires.

  Default timeout is #{@await_timeout}ms.
  """
  @spec await_ready(timeout()) :: :ok | {:error, :timeout}
  def await_ready(timeout \\ @await_timeout) do
    if ready?() do
      :ok
    else
      Phoenix.PubSub.subscribe(CordialCantina.PubSub, @ready_topic)

      receive do
        :mnesia_ready -> :ok
      after
        timeout -> {:error, :timeout}
      end
    end
  end

  @doc """
  Returns the current Mnesia status for health checks.

  Returns a map with:
  - `:ready` - boolean indicating if Mnesia is initialized
  - `:tables` - list of initialized tables
  - `:node` - current node name
  """
  @spec health_check() :: map()
  def health_check do
    GenServer.call(__MODULE__, :health_check)
  catch
    :exit, _ ->
      %{ready: false, tables: [], node: node(), error: :server_not_running}
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    Logger.info("Mnesia.Server starting initialization")

    case initialize_mnesia() do
      :ok ->
        state = %{
          ready: true,
          initialized_at: DateTime.utc_now(),
          tables: list_tables()
        }

        broadcast_ready()
        Logger.info("Mnesia.Server initialization complete")
        {:ok, state}

      {:error, reason} ->
        Logger.error("Mnesia.Server initialization failed: #{inspect(reason)}")
        {:stop, {:initialization_failed, reason}}
    end
  end

  @impl true
  def handle_call(:ready?, _from, state) do
    {:reply, state.ready, state}
  end

  @impl true
  def handle_call(:health_check, _from, state) do
    health = %{
      ready: state.ready,
      tables: state.tables,
      node: node(),
      initialized_at: state.initialized_at
    }

    {:reply, health, state}
  end

  # Private Functions

  defp initialize_mnesia do
    # Ensure Mnesia is stopped before schema operations
    :mnesia.stop()

    case :mnesia.create_schema([node()]) do
      :ok ->
        Logger.info("Mnesia schema created (first boot)")
        start_and_create_tables()

      {:error, {_, {:already_exists, _}}} ->
        Logger.info("Mnesia schema exists (subsequent boot)")
        start_and_wait_for_tables()

      {:error, reason} ->
        {:error, {:schema_creation_failed, reason}}
    end
  end

  defp start_and_create_tables do
    case :mnesia.start() do
      :ok ->
        create_tables()

      {:error, reason} ->
        {:error, {:mnesia_start_failed, reason}}
    end
  end

  defp start_and_wait_for_tables do
    case :mnesia.start() do
      :ok ->
        wait_for_tables()

      {:error, reason} ->
        {:error, {:mnesia_start_failed, reason}}
    end
  end

  defp create_tables do
    # Per R8: Iterative schema definition. Start with no application tables.
    # Tables will be added as features require them.
    #
    # Example table creation (for future reference):
    # :mnesia.create_table(:market_data, [
    #   attributes: [:id, :timestamp, :price, :volume],
    #   type: :ordered_set,
    #   ram_copies: [node()]
    # ])

    Logger.info("Mnesia tables created (none defined yet - iterative schema)")
    :ok
  end

  defp wait_for_tables do
    tables = :mnesia.system_info(:local_tables) -- [:schema]

    case tables do
      [] ->
        Logger.info("No application tables to wait for")
        :ok

      _ ->
        case :mnesia.wait_for_tables(tables, 30_000) do
          :ok ->
            Logger.info("Mnesia tables ready: #{inspect(tables)}")
            :ok

          {:timeout, pending} ->
            {:error, {:table_timeout, pending}}

          {:error, reason} ->
            {:error, {:table_wait_failed, reason}}
        end
    end
  end

  defp list_tables do
    :mnesia.system_info(:local_tables) -- [:schema]
  end

  defp broadcast_ready do
    Phoenix.PubSub.broadcast(CordialCantina.PubSub, @ready_topic, :mnesia_ready)
  end
end
