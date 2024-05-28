defmodule PtahServerWeb.SwarmLive.Show do
  use PtahServerWeb, :live_view

  alias PtahServer.Swarms

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:swarm, Swarms.get_swarm!(id))}
  end

  defp page_title(:show), do: "Show Swarm"
  defp page_title(:edit), do: "Edit Swarm"
end
