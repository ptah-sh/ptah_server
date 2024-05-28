defmodule PtahServerWeb.ServerLive.Show do
  require Logger
  alias PtahServerWeb.Presence
  use PtahServerWeb, :live_view

  alias PtahServer.Servers

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {server_id, _} = Integer.parse(id)

    socket = assign(socket, :agent, PtahServerWeb.Presence.get_agent(server_id))

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
     |> assign(:server, Servers.get_server!(id))}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:join, [agent]}}, socket) do
    {:noreply, assign(socket, :agent, agent)}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:leave, metas}}, socket) do
    Logger.info("Leaving #{inspect(metas)}")

    {:noreply, assign(socket, :agent, nil)}
  end

  @impl true
  def handle_event("create_swarm", _unsigned_params, socket) do
    Logger.debug("handle_event: #{inspect(socket.assigns.server)}")

    # PtahServerWeb.Presence.cmd(socket.assigns.server, "swarm:create", %{})
    PtahServerWeb.Presence.swarm_create(socket.assigns.server)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Server"
  defp page_title(:edit), do: "Edit Server"
end
