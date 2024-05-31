defmodule PtahServerWeb.StackLive.Components.ServiceComponent do
  require Logger
  alias PtahServer.Servers
  alias PtahServerWeb.StackLive.Components.PortComponent
  use PtahServerWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:bind_volumes, false)
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

      <div>Ports</div>
      <table>
        <tbody>
          <.inputs_for :let={port} field={@field[:published_ports]}>
            <.live_component
              module={PortComponent}
              id={port.id}
              field={port}
              stack_schema={Enum.at(@stack_schema["ports"], port.index)}
            />
          </.inputs_for>
        </tbody>
      </table>

      <div>Volumes</div>
      <%= for volume <- @stack_schema["volumes"] do %>
        <p><%= volume["name"] %>: <%= volume["description"] %> (container <%= volume["target"] %>)</p>
      <% end %>
      <div :if={@stack_schema["volumes"]}>
        <.input
          type="checkbox"
          name=""
          checked={@bind_volumes}
          label="Bind Volumes?"
          phx-target={@myself}
          phx-change="change_bind_volumes"
        />

        <div :if={@bind_volumes}>
          <%= inspect(@field[:server_id].value) %>
          <.input
            type="select"
            field={@field[:server_id]}
            options={@servers}
            prompt="Select a Server"
          />
        </div>
      </div>
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
    bind_volumes = !socket.assigns.bind_volumes

    socket =
      socket
      |> assign(:bind_volumes, bind_volumes)
      |> assign_servers()

    {:noreply, socket}
  end

  defp assign_servers(socket) do
    servers =
      if socket.assigns.bind_volumes do
        Enum.map(Servers.list_by_swarm_id(socket.assigns.swarm_id), &{&1.name, &1.id})
      else
        []
      end

    assign(socket, :servers, servers)
  end
end
