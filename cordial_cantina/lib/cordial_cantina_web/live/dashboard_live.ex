defmodule CordialCantinaWeb.DashboardLive do
  @moduledoc """
  LiveView dashboard for Cordial Cantina.

  This is a stub implementation. Real-time market data and trading status
  will be displayed here in future phases.
  """

  use CordialCantinaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Dashboard", nif_status: check_nif_status())}
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
end
