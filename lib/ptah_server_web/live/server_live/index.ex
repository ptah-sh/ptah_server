defmodule PtahServerWeb.ServerLive.Index do
  alias PtahServerWeb.Presence
  use PtahServerWeb, :live_view
  require Logger

  on_mount {PtahServerWeb.UserAuth, :mount_current_user}

  alias PtahServer.Servers
  alias PtahServer.Servers.Server

  @impl true
  def mount(_params, _session, socket) do
    socket = stream(socket, :servers, Enum.map(Servers.list_servers(), &map_server_view/1))

    socket =
      if connected?(socket) do
        PtahServerWeb.Presence.subscribe_team()

        socket
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Server")
    |> assign(:server, Servers.get_server!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Server")
    |> assign(:server, %Server{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Servers")
    |> assign(:server, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO: map server to view

    server = Servers.get_server!(id)
    {:ok, _} = Servers.delete_server(server)

    {:noreply, stream_delete(socket, :servers, server)}
  end

  @impl true
  def handle_info({PtahServerWeb.ServerLive.FormComponent, {:saved, server}}, socket) do
    {:noreply, stream_insert(socket, :servers, map_server_view(server))}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:join, server_id, _metas}}, socket) do
    {:noreply, stream_insert(socket, :servers, map_server_view(Servers.get_server!(server_id)))}
  end

  @impl true
  def handle_info({PtahServerWeb.Presence, {:leave, server_id, _metas}}, socket) do
    {:noreply, stream_insert(socket, :servers, map_server_view(Servers.get_server!(server_id)))}
  end

  defp map_server_view(server) do
    %{
      id: server.id,
      server: server,
      agent: Enum.at(Presence.get_by_key("team:14", server.id), 0)
    }
  end
end
