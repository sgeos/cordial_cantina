defmodule CordialCantina.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    # Verify NIF loaded successfully
    :ok = CordialCantina.Nif.nop()
    Logger.info("NIF loaded successfully")

    children = [
      CordialCantinaWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:cordial_cantina, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CordialCantina.PubSub},
      # Start Mnesia before dependent processes
      CordialCantina.Mnesia.Server,
      # Start the Finch HTTP client
      {Finch, name: CordialCantina.Finch},
      # Start a worker by calling: CordialCantina.Worker.start_link(arg)
      # {CordialCantina.Worker, arg},
      # Start to serve requests, typically the last entry
      CordialCantinaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CordialCantina.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CordialCantinaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
