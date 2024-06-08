defmodule PtahServerWeb.DockerRegistryLive.Show do
  use PtahServerWeb, :live_view

  alias PtahServer.DockerRegistries

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:docker_registry, DockerRegistries.get_docker_registry!(id))}
  end

  defp page_title(:show), do: "Show Docker registry"
  defp page_title(:edit), do: "Edit Docker registry"
end
