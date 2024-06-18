defmodule PtahServerWeb.TlsCertLive.Show do
  use PtahServerWeb, :live_view

  alias PtahServer.TlsCerts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tls_cert, TlsCerts.get_tls_cert!(id))}
  end

  defp page_title(:show), do: "Show Tls cert"
  defp page_title(:edit), do: "Edit Tls cert"
end
