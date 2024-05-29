defmodule PtahServerWeb.StackLive.Components.ServiceComponent do
  alias PtahServerWeb.StackLive.Components.PortComponent
  use PtahServerWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3 class="text-lg border-t-2">
        Service: <%= @field.params["name"] %>
        <span class="text-sm italic">
          (<%= @stack_schema["image"] %>)
        </span>

        <p class="text-sm italic">
          <%= @stack_schema["description"] %>
        </p>
      </h3>

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

      <%!-- Temporarily commented out --%>
      <%!-- <%= for {name, volume} <- value["volumes"] do %>
              <p><%= name %>: <%= volume["description"] %> (container <%= volume["target"] %>)</p>
              <input
                type="text"
                name={name}
                placeholder="/home/ptah/volumes/$stack-name/$container-name"
                readonly
              />
          <% end %> --%>
    </div>
    """
  end
end
