defmodule PtahServerWeb.StackLive.Components.PortComponent do
  require Logger
  use PtahServerWeb, :live_component

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
        <input
          type="hidden"
          id={@field[:name].id}
          name={@field[:name].name}
          value={@stack_schema["name"]}
        />

        <div>
          <.inputs_for :let={endpoint_spec} field={@field[:docker]}>
            <.input type="checkbox" field={endpoint_spec[:exposed]} label="Expose via Swarm Nodes?" />

            <%= if endpoint_spec[:exposed].value do %>
              <.input
                type="number"
                field={endpoint_spec[:published_port]}
                placeholder="Enter Ingress Port"
                label=""
              />
              <small>Should be unique across Swarm Cluster</small>
            <% end %>
          </.inputs_for>
        </div>

        <div>
          <.inputs_for :let={caddy_spec} field={@field[:caddy]}>
            <.input field={caddy_spec[:enabled]} type="checkbox" label="Expose to Internet?" />

            <%= if caddy_spec[:enabled].value do %>
              <.input field={caddy_spec[:domain]} type="text" label="Domain" />
              <.input field={caddy_spec[:port]} type="text" label="Port" />
              <.input field={caddy_spec[:path]} type="text" label="Path" />
            <% end %>
          </.inputs_for>
        </div>
      </td>
    </tr>
    """
  end
end
