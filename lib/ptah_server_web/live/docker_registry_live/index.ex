defmodule PtahServerWeb.DockerRegistryLive.Index do
  use PtahServerWeb, :live_view

  alias PtahServer.DockerRegistries
  alias PtahServer.DockerRegistries.DockerRegistry

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :docker_registries, DockerRegistries.list_docker_registries())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Docker registry")
    |> assign(:docker_registry, DockerRegistries.get_docker_registry!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Docker registry")
    |> assign(:docker_registry, %DockerRegistry{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Docker registries")
    |> assign(:docker_registry, nil)
  end

  @impl true
  def handle_info({PtahServerWeb.DockerRegistryLive.FormComponent, {:saved, docker_registry}}, socket) do
    {:noreply, stream_insert(socket, :docker_registries, docker_registry)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    docker_registry = DockerRegistries.get_docker_registry!(id)
    {:ok, _} = DockerRegistries.delete_docker_registry(docker_registry)

    {:noreply, stream_delete(socket, :docker_registries, docker_registry)}
  end
end
