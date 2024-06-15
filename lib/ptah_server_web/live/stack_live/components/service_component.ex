defmodule PtahServerWeb.StackLive.Components.ServiceComponent do
  require Logger
  alias PtahServer.DockerRegistries
  alias PtahServer.Servers
  use PtahServerWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:servers, [])
      |> assign(:docker_registries, [])

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_servers()
      |> assign_docker_registries()

    {:ok, socket}
  end

  defp assign_servers(socket) do
    servers =
      Enum.map(Servers.list_by_swarm_id(socket.assigns.swarm_id), &{&1.name, &1.id})

    assign(socket, :servers, servers)
  end

  defp assign_docker_registries(socket) do
    registries = DockerRegistries.list_by_swarm_id(socket.assigns.swarm_id)

    assign(
      socket,
      :docker_registries,
      [{"Docker Hub or an Anonymous one (ghcr.io, etc.)", ""}] ++
        Enum.map(registries, &{&1.name, &1.id})
    )
  end
end
