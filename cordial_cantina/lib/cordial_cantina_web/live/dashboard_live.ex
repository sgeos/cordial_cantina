defmodule CordialCantinaWeb.DashboardLive do
  @moduledoc """
  LiveView dashboard for Cordial Cantina.

  Displays real-time market data, system status, and trading positions.
  Subscribes to price updates from the BirdeyeWebSocket integration.

  URL: http://localhost:4000/dashboard
  """

  use CordialCantinaWeb, :live_view

  @tick_interval 1000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(CordialCantina.PubSub, "dashboard:tick")
      Phoenix.PubSub.subscribe(CordialCantina.PubSub, "market_data:price_feed")
      schedule_tick()
    end

    {:ok,
     assign(socket,
       page_title: "Dashboard",
       nif_status: check_nif_status(),
       current_time: DateTime.utc_now(),
       tick_count: 0,
       prices: %{},
       last_update: nil
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
  def handle_info({:price_update, price_data}, socket) do
    symbol = price_data[:symbol] || "UNKNOWN"
    prices = Map.put(socket.assigns.prices, symbol, price_data)

    {:noreply,
     assign(socket,
       prices: prices,
       last_update: DateTime.utc_now()
     )}
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-primary">Cordial Cantina Dashboard</h1>
        <a href="/" class="btn btn-ghost btn-sm">Home</a>
      </div>

      <div class="card bg-base-100 shadow-xl mb-4">
        <div class="card-body">
          <h2 class="card-title">System Status</h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="stat bg-base-200 rounded-box p-4">
              <div class="stat-title text-xs">NIF Status</div>
              <div class={"stat-value text-lg " <> if @nif_status == :ok, do: "text-success", else: "text-error"}>
                {@nif_status}
              </div>
            </div>
            <div class="stat bg-base-200 rounded-box p-4">
              <div class="stat-title text-xs">Phase</div>
              <div class="stat-value text-lg text-primary">V0.2</div>
              <div class="stat-desc text-xs">Market Data</div>
            </div>
            <div class="stat bg-base-200 rounded-box p-4">
              <div class="stat-title text-xs">Server Time</div>
              <div class="stat-value text-sm font-mono">
                {Calendar.strftime(@current_time, "%H:%M:%S")}
              </div>
              <div class="stat-desc text-xs">UTC</div>
            </div>
            <div class="stat bg-base-200 rounded-box p-4">
              <div class="stat-title text-xs">Tick Count</div>
              <div class="stat-value text-lg font-mono">{@tick_count}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-xl mb-4">
        <div class="card-body">
          <h2 class="card-title">
            Market Data
            <span :if={@last_update} class="badge badge-success badge-sm">Live</span>
            <span :if={!@last_update} class="badge badge-warning badge-sm">Waiting</span>
          </h2>
          <div :if={map_size(@prices) > 0} class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div :for={{symbol, data} <- @prices} class="stat bg-base-200 rounded-box p-4">
              <div class="stat-title">{symbol}</div>
              <div class="stat-value text-lg">${format_price(data[:close])}</div>
              <div class="stat-desc">
                H: ${format_price(data[:high])} L: ${format_price(data[:low])}
              </div>
            </div>
          </div>
          <div :if={map_size(@prices) == 0} class="text-base-content/60">
            <p>No price data received yet.</p>
            <p class="text-xs mt-2">
              Connect to Birdeye WebSocket to receive real-time price updates.
              Requires BIRDEYE_API_KEY environment variable.
            </p>
          </div>
          <div :if={@last_update} class="text-xs text-base-content/40 mt-2">
            Last update: {Calendar.strftime(@last_update, "%H:%M:%S")} UTC
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <h2 class="card-title">Trading Status</h2>
          <p class="text-base-content/60 italic">
            No active positions. Trading functionality will be implemented in future phases.
          </p>
        </div>
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

  defp format_price(nil), do: "-"
  defp format_price(price) when is_float(price), do: :erlang.float_to_binary(price, decimals: 2)
  defp format_price(price), do: to_string(price)
end
