defmodule PtahServerWeb.DockerConfigLive.Show do
  use PtahServerWeb, :live_view

  alias PtahServer.DockerConfigs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:docker_config, DockerConfigs.get_docker_config!(id))}
  end

  defp page_title(:show), do: "Show Docker config"
  defp page_title(:edit), do: "Edit Docker config"
end
