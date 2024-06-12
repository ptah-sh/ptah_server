defmodule PtahServerWeb.StackLive.Components.ServiceComponent do
  require Logger
  alias Phoenix.HTML.Form
  alias PtahServer.DockerRegistries
  alias PtahServer.Servers
  use PtahServerWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:servers, [])
      |> assign(:docker_registries, [])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3 class="text-lg border-t-2">
        Service: <.input field={@field[:name]} type="text" label="Name" disabled={@action != :new} />

        <small :if={@action != :new}>
          Services can not be renamed.
        </small>

        <br />

        <.input field={@field[:service_name]} type="hidden" />

        <small>
          Your service will be accessible on the Swarm cluster via the following endpoint:
        </small>
        <br />
        <small><%= @field[:name].value %>.<%= @stack_name %></small>

        <p class="text-sm italic">
          <%!-- <%= @stack_schema["description"] %> --%>
        </p>
      </h3>

      <.inputs_for :let={spec_field} field={@field[:spec]}>
        <.inputs_for :let={task_template} field={spec_field[:task_template]}>
          <.inputs_for :let={container_spec} field={task_template[:container_spec]}>
            <.input
              field={container_spec[:docker_registry_id]}
              type="select"
              label="Docker Registry"
              options={@docker_registries}
            />

            <.input field={container_spec[:image]} type="text" label="Image" />

            <div>
              Environment Variables
              <.button
                type="button"
                name={"#{container_spec[:env_sort].name}[]"}
                phx-value="new"
                phx-click={JS.dispatch("change")}
              >
                Add
              </.button>
            </div>

            <table>
              <tbody>
                <.inputs_for :let={env_spec} field={container_spec[:env]}>
                  <tr>
                    <td>
                      <.input field={env_spec[:name]} type="text" label="Name" />
                    </td>
                    <td>
                      <.input field={env_spec[:value]} type="text" label="Value" />
                    </td>
                    <td>
                      <.button
                        type="button"
                        name={"#{container_spec[:env_drop].name}[]"}
                        value={env_spec.index}
                        phx-click={JS.dispatch("change")}
                      >
                        Remove
                      </.button>
                    </td>
                  </tr>
                </.inputs_for>
              </tbody>
            </table>
          </.inputs_for>
        </.inputs_for>

        <.inputs_for :let={endpoint_spec} field={spec_field[:endpoint_spec]}>
          <div>
            Publish Ports via Swarm Nodes
            <.button
              type="button"
              name={"#{endpoint_spec[:ports_sort].name}[]"}
              phx-value="new"
              phx-click={JS.dispatch("change")}
            >
              Add
            </.button>
          </div>
          <table>
            <tbody>
              <.inputs_for :let={port_spec} field={endpoint_spec[:ports]}>
                <tr>
                  <td>
                    <.input field={port_spec[:target_port]} type="text" label="Target Port" />
                  </td>
                  <td>
                    <.input field={port_spec[:published_port]} type="text" label="Published Port" />
                  </td>
                  <td>
                    <.button
                      type="button"
                      name={"#{endpoint_spec[:ports_drop].name}[]"}
                      value={port_spec.index}
                      phx-click={JS.dispatch("change")}
                    >
                      Remove
                    </.button>
                  </td>
                </tr>
              </.inputs_for>
            </tbody>
          </table>

          <div>
            Publish to the Internet via Caddy
            <.button
              type="button"
              name={"#{endpoint_spec[:caddy_sort].name}[]"}
              phx-value="new"
              phx-click={JS.dispatch("change")}
            >
              Add
            </.button>
          </div>
          <table>
            <tbody>
              <.inputs_for :let={handler_spec} field={endpoint_spec[:caddy]}>
                <tr>
                  <td>
                    <.input field={handler_spec[:target_port]} type="text" label="Target Port" />
                  </td>
                  <td>
                    <.input field={handler_spec[:published_port]} type="text" label="Published Port" />
                  </td>
                  <td><.input field={handler_spec[:domain]} type="text" label="Domain" /></td>
                  <td><.input field={handler_spec[:path]} type="text" label="Path" /></td>
                  <td>
                    <.button
                      type="button"
                      name={"#{endpoint_spec[:caddy_drop].name}[]"}
                      value={handler_spec.index}
                      phx-click={JS.dispatch("change")}
                    >
                      Remove
                    </.button>
                  </td>
                </tr>
              </.inputs_for>
            </tbody>
          </table>
        </.inputs_for>

        <.input type="checkbox" field={spec_field[:bind_volumes]} label="Bind Volumes?" />

        <div :if={Form.normalize_value("checkbox", spec_field[:bind_volumes].value)}>
          <.input
            type="select"
            field={spec_field[:placement_server_id]}
            options={@servers}
            prompt="Select a Server"
            disabled={spec_field[:placement_server_id].value && @action != :new}
          />

          <small :if={@action != :new}>Placement can not be changed.</small>

          <div>
            Volumes
          </div>
          <.inputs_for :let={task_template} field={spec_field[:task_template]}>
            <.inputs_for :let={container_spec} field={task_template[:container_spec]}>
              <.button
                type="button"
                name={"#{container_spec[:mounts_sort].name}[]"}
                phx-value="new"
                phx-click={JS.dispatch("change")}
              >
                Add
              </.button>

              <table>
                <tbody>
                  <.inputs_for :let={volume_spec} field={container_spec[:mounts]}>
                    <tr>
                      <td>
                        <.input field={volume_spec[:name]} type="text" label="Name" />
                      </td>
                      <td>
                        <.input field={volume_spec[:target]} type="text" label="Target" />
                      </td>
                      <td>
                        <.button
                          type="button"
                          name={"#{container_spec[:mounts_drop].name}[]"}
                          value={volume_spec.index}
                          phx-click={JS.dispatch("change")}
                        >
                          Remove
                        </.button>
                      </td>
                    </tr>
                  </.inputs_for>
                </tbody>
              </table>
            </.inputs_for>
          </.inputs_for>
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
      |> assign_docker_registries()

    {:ok, socket}
  end

  defp assign_servers(socket) do
    servers =
      Enum.map(Servers.list_by_swarm_id(socket.assigns.swarm_id), &{&1.name, &1.id})

    assign(socket, :servers, servers)
  end

  defp assign_docker_registries(socket) do
    registries = DockerRegistries.list_by_swarm_id(socket.assigns.swarm_id)

    assign(
      socket,
      :docker_registries,
      [{"Docker Hub or an Anonymous one (ghcr.io, etc.)", ""}] ++
        Enum.map(registries, &{&1.name, &1.id})
    )
  end
end
