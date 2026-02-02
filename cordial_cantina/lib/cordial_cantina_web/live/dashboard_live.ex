defmodule CordialCantinaWeb.DashboardLive do
  @moduledoc """
  LiveView dashboard for Cordial Cantina.

  This is a stub implementation. Real-time market data and trading status
  will be displayed here in future phases.

  URL: http://localhost:4000/dashboard
  """

  use CordialCantinaWeb, :live_view

  @tick_interval 1000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(CordialCantina.PubSub, "dashboard:tick")
      schedule_tick()
    end

    {:ok,
     assign(socket,
       page_title: "Dashboard",
       nif_status: check_nif_status(),
       current_time: DateTime.utc_now(),
       tick_count: 0
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    Phoenix.PubSub.broadcast(CordialCantina.PubSub, "dashboard:tick", {:tick, DateTime.utc_now()})
    schedule_tick()
    {:noreply, socket}
  end

  @impl true
  def handle_info({:tick, datetime}, socket) do
    {:noreply,
     assign(socket,
       current_time: datetime,
       tick_count: socket.assigns.tick_count + 1
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <h1 class="text-2xl font-bold mb-4">Cordial Cantina Dashboard</h1>

      <div class="bg-white shadow rounded-lg p-6 mb-4">
        <h2 class="text-lg font-semibold mb-2">System Status</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <span class="text-gray-600">NIF Status:</span>
            <span class={"ml-2 font-medium " <> if @nif_status == :ok, do: "text-green-600", else: "text-red-600"}>
              {@nif_status}
            </span>
          </div>
          <div>
            <span class="text-gray-600">Phase:</span>
            <span class="ml-2 font-medium">0 (Foundation)</span>
          </div>
        </div>
      </div>

      <div class="bg-white shadow rounded-lg p-6 mb-4">
        <h2 class="text-lg font-semibold mb-2">Real-Time Status</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <span class="text-gray-600">Server Time (UTC):</span>
            <span class="ml-2 font-mono text-blue-600">
              {Calendar.strftime(@current_time, "%Y-%m-%d %H:%M:%S")}
            </span>
          </div>
          <div>
            <span class="text-gray-600">Tick Count:</span>
            <span class="ml-2 font-mono">{@tick_count}</span>
          </div>
        </div>
        <p class="text-xs text-gray-400 mt-2">
          LiveView PubSub is active. Time updates every second.
        </p>
      </div>

      <div class="bg-white shadow rounded-lg p-6">
        <h2 class="text-lg font-semibold mb-2">Trading Status</h2>
        <p class="text-gray-500 italic">
          No active positions. Trading functionality will be implemented in future phases.
        </p>
      </div>
    </div>
    """
  end

  defp check_nif_status do
    case CordialCantina.Nif.nop() do
      :ok -> :ok
      _ -> :error
    end
  rescue
    _ -> :not_loaded
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end
end
