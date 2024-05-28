defmodule PtahServerWeb.SwarmLive.Index do
  use PtahServerWeb, :live_view

  alias PtahServer.Swarms
  alias PtahServer.Swarms.Swarm

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :swarms, Swarms.list_swarms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Swarm")
    |> assign(:swarm, Swarms.get_swarm!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Swarm")
    |> assign(:swarm, %Swarm{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Swarms")
    |> assign(:swarm, nil)
  end

  @impl true
  def handle_info({PtahServerWeb.SwarmLive.FormComponent, {:saved, swarm}}, socket) do
    {:noreply, stream_insert(socket, :swarms, swarm)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    swarm = Swarms.get_swarm!(id)
    {:ok, _} = Swarms.delete_swarm(swarm)

    {:noreply, stream_delete(socket, :swarms, swarm)}
  end
end
