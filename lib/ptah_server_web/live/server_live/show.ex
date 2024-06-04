defmodule PtahServerWeb.ServerLive.Show do
  require Logger
  alias PtahServerAgent.AgentChannel
  alias PtahServer.Repo
  alias PtahProto.Cmd
  use PtahServerWeb, :live_view

  alias PtahServer.Servers

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {server_id, _} = Integer.parse(id)

    socket =
      assign(socket,
        agent: PtahServerWeb.Presence.get_state(server_id),
        latest_version: GenServer.call(PtahServerAgent.VersionMonitor, :get_latest_version)
      )

    socket =
      if connected?(socket) do
        PtahServerWeb.Presence.subscribe_server(server_id)

        socket
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:server, Repo.preload(Servers.get_server!(id), :swarm))}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:join, [agent]}}, socket) do
    {:noreply, assign(socket, :agent, agent)}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:leave, _metas}}, socket) do
    {:noreply, assign(socket, :agent, nil)}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:swarm_created, server: server}}, socket) do
    {:noreply, assign(socket, :server, Repo.preload(server, :swarm))}
  end

  @impl true
  def handle_event("create_swarm", _unsigned_params, socket) do
    PtahServerWeb.Presence.swarm_create(socket.assigns.server)

    {:noreply, socket}
  end

  @impl true
  def handle_event("upgrade_agent", _unsigned_params, socket) do
    :ok =
      AgentChannel.push(socket.assigns.agent.socket, %Cmd.SelfUpgrade{
        version: socket.assigns.latest_version
      })

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Server"
  defp page_title(:edit), do: "Edit Server"
end
