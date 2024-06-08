defmodule PtahServerWeb.DockerConfigLive.Index do
  use PtahServerWeb, :live_view

  alias PtahServer.DockerConfigs
  alias PtahServer.DockerConfigs.DockerConfig

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :docker_configs, DockerConfigs.list_docker_configs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Docker config")
    |> assign(:docker_config, DockerConfigs.get_docker_config!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Docker config")
    |> assign(:docker_config, %DockerConfig{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Docker configs")
    |> assign(:docker_config, nil)
  end

  @impl true
  def handle_info({PtahServerWeb.DockerConfigLive.FormComponent, {:saved, docker_config}}, socket) do
    {:noreply, stream_insert(socket, :docker_configs, docker_config)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    docker_config = DockerConfigs.get_docker_config!(id)
    {:ok, _} = DockerConfigs.delete_docker_config(docker_config)

    {:noreply, stream_delete(socket, :docker_configs, docker_config)}
  end
end
