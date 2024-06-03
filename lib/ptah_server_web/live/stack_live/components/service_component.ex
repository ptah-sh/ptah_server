defmodule PtahServerWeb.StackLive.Components.ServiceComponent do
  require Logger
  alias PtahServer.Servers
  alias PtahServerWeb.StackLive.Components.PortComponent
  use PtahServerWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:servers, [])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3 class="text-lg border-t-2">
        Service: <%= @stack_schema["name"] %>
        <span class="text-sm italic">
          (<%= @stack_schema["image"] %>)
        </span>

        <p class="text-sm italic">
          <%= @stack_schema["description"] %>
        </p>
      </h3>

      <.inputs_for :let={spec_field} field={@field[:spec]}>
        <.inputs_for :let={endpoint_spec} field={spec_field[:endpoint_spec]}>
          <div>Ports</div>
          <table>
            <tbody>
              <.inputs_for :let={port_spec} field={endpoint_spec[:ports]}>
                <.live_component
                  module={PortComponent}
                  id={port_spec.id}
                  field={port_spec}
                  stack_schema={Enum.at(@stack_schema["ports"], port_spec.index)}
                />
              </.inputs_for>
            </tbody>
          </table>
        </.inputs_for>
        <div>Volumes</div>
        <%= for volume <- @stack_schema["mounts"] do %>
          <p>
            <%= volume["name"] %>: <%= volume["description"] %> (container <%= volume["target"] %>)
          </p>
        <% end %>
        <div :if={@stack_schema["mounts"]}>
          <.input type="checkbox" field={spec_field[:bind_volumes]} label="Bind Volumes?" />

          <div :if={spec_field[:bind_volumes].value}>
            <.input
              type="select"
              field={spec_field[:placement_server_id]}
              options={@servers}
              prompt="Select a Server"
            />
          </div>
        </div>
      </.inputs_for>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_servers()

    {:ok, socket}
  end

  @impl true
  def handle_event("change_bind_volumes", _params, socket) do
    socket =
      socket
      |> assign_servers()

    {:noreply, socket}
  end

  defp assign_servers(socket) do
    servers =
      if socket.assigns.field.params["spec"]["bind_volumes"] do
        Enum.map(Servers.list_by_swarm_id(socket.assigns.swarm_id), &{&1.name, &1.id})
      else
        []
      end

    assign(socket, :servers, servers)
  end
end
