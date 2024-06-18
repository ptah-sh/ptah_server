defmodule PtahServerWeb.DockerSecretLive.Index do
  use PtahServerWeb, :live_view

  alias PtahServer.DockerSecrets
  alias PtahServer.DockerSecrets.DockerSecret

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :docker_secrets, DockerSecrets.list_docker_secrets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Docker secret")
    |> assign(:docker_secret, DockerSecrets.get_docker_secret!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Docker secret")
    |> assign(:docker_secret, %DockerSecret{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Docker secrets")
    |> assign(:docker_secret, nil)
  end

  @impl true
  def handle_info({PtahServerWeb.DockerSecretLive.FormComponent, {:saved, docker_secret}}, socket) do
    {:noreply, stream_insert(socket, :docker_secrets, docker_secret)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    docker_secret = DockerSecrets.get_docker_secret!(id)
    {:ok, _} = DockerSecrets.delete_docker_secret(docker_secret)

    {:noreply, stream_delete(socket, :docker_secrets, docker_secret)}
  end
end
