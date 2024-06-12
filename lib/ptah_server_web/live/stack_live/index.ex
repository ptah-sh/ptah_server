defmodule PtahServerWeb.StackLive.Index do
  alias PtahServer.Repo
  use PtahServerWeb, :live_view

  alias PtahServer.Stacks
  alias PtahServer.Stacks.Stack

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :stacks, Stacks.list_stacks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Stack")
    |> assign(:stack, Stacks.get_stack!(id) |> Repo.preload(:services))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Stack")
    |> assign(:stack, %Stack{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Stacks")
    |> assign(:stack, nil)
  end

  @impl true
  def handle_info({PtahServerWeb.StackLive.FormComponent, {:saved, stack}}, socket) do
    {:noreply, stream_insert(socket, :stacks, stack)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    stack = Stacks.get_stack!(id)
    {:ok, _} = Stacks.delete_stack(stack)

    {:noreply, stream_delete(socket, :stacks, stack)}
  end
end
