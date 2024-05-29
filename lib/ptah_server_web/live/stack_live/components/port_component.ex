defmodule PtahServerWeb.StackLive.Components.PortComponent do
  require Logger
  use PtahServerWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :expose, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <tr>
      <td>
        <div>
          <%= @stack_schema["name"] %>: <%= @stack_schema["target"] %>
        </div>
        <span class="text-sm">
          <%= @stack_schema["description"] %>
        </span>
      </td>
      <td>
        <.input
          type="checkbox"
          name=""
          checked={@expose}
          label="Expose to public?"
          phx-target={@myself}
          phx-change="change_expose"
        />
      </td>
      <td>
        <%= if @expose do %>
          <.input type="number" field={@field[:published_port]} placeholder="test" label="" />
        <% end %>
      </td>
    </tr>
    """
  end

  @impl true
  def handle_event("change_expose", _params, socket) do
    socket = assign(socket, expose: !socket.assigns.expose)

    {:noreply, socket}
  end
end
