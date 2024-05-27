defmodule PtahServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PtahServerWeb.Telemetry,
      PtahServer.Repo,
      {DNSCluster, query: Application.get_env(:ptah_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PtahServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PtahServer.Finch},
      # Start a worker by calling: PtahServer.Worker.start_link(arg)
      # {PtahServer.Worker, arg},
      # Start to serve requests, typically the last entry
      PtahServerWeb.Endpoint,
      PtahServerWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PtahServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PtahServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
