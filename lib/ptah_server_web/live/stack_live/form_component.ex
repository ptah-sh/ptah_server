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

    stacks =
      Enum.map(Marketplace.list_stacks(), &{&1["name"], &1["name"]}) ++ [{"custom", "@custom@"}]

    socket =
      socket
      |> assign(:swarms, swarms)
      |> assign(:stacks, stacks)

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
          disabled={@stack.id}
        />
        <small :if={@stack.id}>Existing stacks can not be moved between Swarms</small>

        <.input
          type="select"
          field={@form[:stack_name]}
          label="Stack Template"
          options={@stacks}
          prompt="Select stack template"
          phx-change="change_stack"
        />

        <%= if @form[:stack_name].value && @form[:stack_name].value != "" do %>
          <.input field={@form[:stack_version]} type="hidden" />

          <.input field={@form[:name]} type="text" label="Name" disabled={@action != :new} />

          <small :if={@action != :new}>Stacks can not be renamed.</small>

          <h2 class="text-xl font-semibold">
            <%!-- <%= @stack_schema["name"] %>@<%= @stack_schema["version"] %> --%>
          </h2>

          <div>
            Services
            <.button
              type="button"
              name={"#{@form[:services_sort].name}[]"}
              value="new"
              phx-click={JS.dispatch("change")}
            >
              Add
            </.button>
          </div>

          <%!-- <.error :for={msg <- Enum.map(@form[:services].errors, &CoreComponents.translate_error(&1))}>
            <%= msg %>
          </.error> --%>
          <.errors for_field={@form[:services]} />

          <%!-- <p class="text-sm"><%= @stack_schema["description"] %></p> --%>
          <.inputs_for :let={service} field={@form[:services]}>
            <.button
              type="button"
              name={"#{@form[:services_drop].name}[]"}
              value={service.index}
              phx-click={JS.dispatch("change")}
            >
              Remove
            </.button>
            <.live_component
              module={ServiceComponent}
              id={service.id}
              field={service}
              action={
                if service.data.id == nil do
                  :new
                else
                  :edit
                end
              }
              swarm_id={@form[:swarm_id].value}
              stack_name={@form[:name].value}
            />
          </.inputs_for>
        <% end %>

        <.debug value={@form} />

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

    params =
      if Map.has_key?(params, "services") do
        Map.update!(params, "services", fn services ->
          Logger.debug("services: #{inspect(services)}")

          # TODO: move list to map conversion to the form initialization.
          #   Currently the form is initialized as a list, but it is being changed to map after first interaction with the form
          services =
            if is_list(services) do
              services
              |> Enum.with_index()
              |> Enum.map(fn {service, index} ->
                {index, service}
              end)
              |> Map.new()
            else
              services
            end

          services
          |> Enum.map(fn {key, service} ->
            {key,
             Map.update(service, "spec", %{}, fn spec ->
               Map.delete(spec, "placement_server_id")
             end)}
          end)
          |> Map.new(& &1)
        end)
      else
        params
      end

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

    stack_assigns =
      case stack_params["stack_name"] do
        "@custom@" -> %{}
        "" -> %{}
        stack_name -> map_stack_template_to_form(stack_name)
      end

    changeset =
      socket.assigns.stack
      |> Stacks.change_stack(Map.merge(stack_params, stack_assigns))
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"stack" => stack_params}, socket) do
    save_stack(socket, socket.assigns.action, stack_params)
  end

  defp save_stack(socket, :new, stack_params) do
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp map_stack_template_to_form(stack_name) do
    stack_template = Marketplace.get_stack(stack_name)

    %{
      "name" => stack_template["name"],
      "stack_name" => stack_template["name"],
      "stack_version" => stack_template["version"],
      "services" =>
        Enum.map(stack_template["services"], fn service ->
          %{
            "name" => service["name"],
            "service_name" => service["name"],
            "spec" => %{
              "bind_volumes" => !Enum.empty?(service["mounts"]),
              "task_template" => %{
                "container_spec" => %{
                  "image" => service["image"],
                  "env" =>
                    Enum.map(service["env"], fn env ->
                      %{
                        "name" => env["name"],
                        "value" => env["value"]
                      }
                    end),
                  "mounts" =>
                    Enum.map(service["mounts"], fn mount ->
                      %{
                        "name" => mount["name"],
                        "target" => mount["target"]
                      }
                    end)
                }
              }
            }
          }
        end)
    }
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
