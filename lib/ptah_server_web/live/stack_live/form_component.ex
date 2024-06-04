defmodule PtahServerWeb.StackLive.FormComponent do
  require Logger
  alias PtahServer.Stacks.Stack
  alias PtahServerWeb.Presence
  alias PtahServerWeb.StackLive.Components.ServiceComponent
  alias PtahServer.Marketplace
  alias PtahServer.Swarms.Swarm
  alias PtahServer.Repo
  use PtahServerWeb, :live_component

  alias PtahServer.Stacks

  @impl true
  def mount(socket) do
    swarms = Enum.map(Repo.all(Swarm), &{&1.name, &1.id})

    stacks = Enum.map(Marketplace.list_stacks(), &{&1["name"], &1["name"]})

    socket =
      socket
      |> assign(:swarms, swarms)
      |> assign(:stacks, stacks)
      |> assign(:stack_schema, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
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
        <.input
          type="select"
          field={@form[:swarm_id]}
          label="Swarm"
          options={@swarms}
          phx-target={@myself}
          phx-change="change_swarm"
        />

        <.input
          type="select"
          field={@form[:stack_name]}
          label="Stack Template"
          options={@stacks}
          prompt="Select stack template"
          phx-change="change_stack"
        />

        <%= if (@stack_schema) do %>
          <.input field={@form[:name]} type="text" label="Name" />

          <h2 class="text-xl font-semibold">
            <%= @stack_schema["name"] %>@<%= @stack_schema["version"] %>
          </h2>

          <p class="text-sm"><%= @stack_schema["description"] %></p>
          <.inputs_for :let={service} field={@form[:services]}>
            <.live_component
              module={ServiceComponent}
              id={service.id}
              field={service}
              stack_schema={Enum.at(@stack_schema["services"], service.index)}
              swarm_id={@form[:swarm_id].value}
              stack_name={@form[:name].value}
            />
          </.inputs_for>
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
    changeset =
      Stacks.change_stack(%Stack{
        stack
        | swarm_id: stack.swarm_id || List.first(socket.assigns.swarms) |> elem(1)
      })

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

  @impl true
  def handle_event("change_swarm", %{"stack" => stack_params}, socket) do
    params =
      socket.assigns.form.params
      |> Map.merge(stack_params)
      |> Map.update!("services", fn services ->
        Enum.map(services, &Map.delete(&1, "server_id"))
      end)

    changeset =
      socket.assigns.stack
      |> Stacks.change_stack(params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign_form(changeset)

    {:noreply, socket}
  end

  @impl true
  def handle_event("change_stack", %{"stack" => stack_params}, socket) do
    # TODO: saving only swarm_id here. Need to create nested form to drop everything when swarm changed?
    stack_params =
      Map.merge(stack_params, %{"swarm_id" => socket.assigns.form[:swarm_id].value})

    Logger.warning("stack_params: #{inspect(stack_params)}")

    socket =
      if stack_params["stack_name"] do
        assign(socket, :stack_schema, Marketplace.get_stack(stack_params["stack_name"]))
      else
        assign(socket, :stack_schema, nil)
      end

    stack_schema = socket.assigns.stack_schema

    stack_params =
      if stack_schema do
        Map.merge(stack_params, %{"name" => stack_schema["name"]})
      else
        Map.merge(stack_params, %{"name" => ""})
      end

    stack_params =
      if socket.assigns.stack_schema do
        Map.merge(stack_params, %{
          "services" =>
            Enum.map(stack_schema["services"], fn service_spec ->
              %{
                "spec" => %{
                  "task_template" => %{
                    "container_spec" => %{
                      "mounts" => Enum.map(service_spec["mounts"], &%{"name" => &1["name"]})
                    }
                  },
                  "endpoint_spec" => %{
                    "ports" =>
                      Enum.map(
                        service_spec["ports"],
                        &%{"name" => &1["name"], "published_port" => nil}
                      )
                  }
                }
              }
            end)
        })
      else
        stack_params
      end

    changeset =
      socket.assigns.stack
      |> Stacks.change_stack(stack_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"stack" => stack_params}, socket) do
    save_stack(socket, socket.assigns.action, stack_params)
  end

  defp save_stack(socket, :new, stack_params) do
    stack_params = assign_stack_params(stack_params, socket)

    case Stacks.create_stack(stack_params) do
      {:ok, stack} ->
        # TODO: rollback insert on stack_create failure
        :ok = Presence.stack_create(stack)

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

  defp assign_stack_params(stack_params, socket) do
    stack_schema = socket.assigns.stack_schema

    if stack_schema do
      Map.merge(stack_params, %{
        "stack_name" => stack_schema["name"],
        "stack_version" => stack_schema["version"],
        "services" =>
          Enum.with_index(stack_schema["services"], fn service_spec, index ->
            map_service_params(
              stack_params,
              stack_params["services"][Integer.to_string(index)],
              service_spec
            )
          end)
      })
    else
      stack_params
    end
  end

  defp map_service_params(stack_params, service_params, service_spec) do
    Map.merge(
      service_params,
      %{
        "name" => "#{stack_params["name"]}_#{service_spec["name"]}",
        "service_name" => service_spec["name"],
        "spec" =>
          Map.put(
            service_params["spec"],
            "task_template",
            Map.put(service_params["spec"]["task_template"] || %{}, "container_spec", %{
              "mounts" => Enum.map(service_spec["mounts"], &%{"name" => &1["name"]})
            })
          )
      }
    )
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
