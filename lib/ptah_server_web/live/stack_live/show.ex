defmodule PtahServerWeb.StackLive.Show do
  alias PtahServer.Repo
  use PtahServerWeb, :live_view

  alias PtahServer.Stacks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:stack, Stacks.get_stack!(id) |> Repo.preload(:services))}
  end

  defp page_title(:show), do: "Show Stack"
  defp page_title(:edit), do: "Edit Stack"
end
