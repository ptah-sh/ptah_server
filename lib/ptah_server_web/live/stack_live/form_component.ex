defmodule PtahServerWeb.StackLive.FormComponent do
  require Jason.Sigil
  use PtahServerWeb, :live_component

  alias PtahServer.Stacks

  @impl true
  def render(assigns) do
    stack_schema =
      Jason.decode!(~s"""
      {
        "$schema": "https://ptah.sh/marketplace/schemas/stack-0.0.1.json",

        "name": "ptah-swarm",
        "version": "0.1.0",
        "description": "Stack describing the Ptah services running on the cluster (except an Agent service which is a system daemon).",
        "author": "Bohdan Shulha <b.shulha@pm.me>",
        "homepage": "https://ptah.sh",
        "license": "MIT",
        "services": {
          "caddy": {
            "description": "The reverse proxy that powers Ptah Swarm cluster.",
            "image": "caddy:2.8-alpine",
            "ports": {
              "http": {
                "target": 80,
                "description": "Caddy HTTP port"
              },
              "https": {
                "target": 443,
                "description": "Caddy HTTPS port"
              }
            },
            "volumes": {
              "data": {
                "target": "/data",
                "description": "Caddy data directory. Should not be treated as a cache."
              },
              "config": {
                "target": "/config",
                "description": "Caddy config directory."
              }
            }
          }
        }
      }
      """)

    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage stack records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="stack-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <select>
          <option>Select Swarm</option>
        </select>
        <.input field={@form[:name]} type="text" label="Name" />
        <select>
          <option>Some Stack</option>
        </select>

        <h2><%= stack_schema["name"] %>@<%= stack_schema["version"] %></h2>
        <p><%= stack_schema["description"] %></p>
        <%= for {key, value} <- stack_schema["services"] do %>
          <h3><%= key %></h3>
          <p><%= value["description"] %></p>
          <p><%= value["image"] %></p>
          <%= for {name, port} <- value["ports"] do %>
            <p><%= name %>: <%= port["description"] %> (default <%= port["target"] %>)</p>
          <% end %>
          <%= for {name, volume} <- value["volumes"] do %>
            <p><%= name %>: <%= volume["description"] %> (container <%= volume["target"] %>)</p>
            <input
              type="text"
              name={name}
              placeholder="/home/ptah/volumes/$stack-name/$container-name"
              readonly
            />
          <% end %>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Deploy Stack</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{stack: stack} = assigns, socket) do
    changeset = Stacks.change_stack(stack)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"stack" => stack_params}, socket) do
    changeset =
      socket.assigns.stack
      |> Stacks.change_stack(stack_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"stack" => stack_params}, socket) do
    save_stack(socket, socket.assigns.action, stack_params)
  end

  defp save_stack(socket, :edit, stack_params) do
    case Stacks.update_stack(socket.assigns.stack, stack_params) do
      {:ok, stack} ->
        notify_parent({:saved, stack})

        {:noreply,
         socket
         |> put_flash(:info, "Stack updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_stack(socket, :new, stack_params) do
    case Stacks.create_stack(stack_params) do
      {:ok, stack} ->
        notify_parent({:saved, stack})

        {:noreply,
         socket
         |> put_flash(:info, "Stack created successfully")
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
