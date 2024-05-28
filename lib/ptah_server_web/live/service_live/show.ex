defmodule PtahServerWeb.ServiceLive.Show do
  use PtahServerWeb, :live_view

  alias PtahServer.Services

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:service, Services.get_service!(id))}
  end

  defp page_title(:show), do: "Show Service"
  defp page_title(:edit), do: "Edit Service"
end
