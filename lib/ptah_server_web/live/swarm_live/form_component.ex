defmodule PtahServerWeb.SwarmLive.FormComponent do
  use PtahServerWeb, :live_component

  alias PtahServer.Swarms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage swarm records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="swarm-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:team_id]} type="number" label="Team" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:ext_id]} type="text" label="Ext" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Swarm</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{swarm: swarm} = assigns, socket) do
    changeset = Swarms.change_swarm(swarm)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"swarm" => swarm_params}, socket) do
    changeset =
      socket.assigns.swarm
      |> Swarms.change_swarm(swarm_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"swarm" => swarm_params}, socket) do
    save_swarm(socket, socket.assigns.action, swarm_params)
  end

  defp save_swarm(socket, :edit, swarm_params) do
    case Swarms.update_swarm(socket.assigns.swarm, swarm_params) do
      {:ok, swarm} ->
        notify_parent({:saved, swarm})

        {:noreply,
         socket
         |> put_flash(:info, "Swarm updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_swarm(socket, :new, swarm_params) do
    case Swarms.create_swarm(swarm_params) do
      {:ok, swarm} ->
        notify_parent({:saved, swarm})

        {:noreply,
         socket
         |> put_flash(:info, "Swarm created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
