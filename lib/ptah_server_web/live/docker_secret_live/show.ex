defmodule PtahServerWeb.DockerSecretLive.Show do
  use PtahServerWeb, :live_view

  alias PtahServer.DockerSecrets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:docker_secret, DockerSecrets.get_docker_secret!(id))}
  end

  defp page_title(:show), do: "Show Docker secret"
  defp page_title(:edit), do: "Edit Docker secret"
end
