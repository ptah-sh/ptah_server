defmodule PtahServerWeb.DockerRegistryLive.FormComponent do
  alias PtahServerWeb.Presence
  alias PtahServer.DockerConfigs
  alias PtahServer.Swarms.Swarm
  alias PtahServer.Repo
  use PtahServerWeb, :live_component

  alias PtahServer.DockerRegistries

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:swarms, Enum.map(Repo.all(Swarm), &{&1.name, &1.id}))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage docker_registry records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="docker_registry-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:swarm_id]} type="select" label="Swarm" options={@swarms} />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:endpoint]} type="text" label="Endpoint" />
        <.input field={@form[:username]} type="text" label="Username" />
        <.input field={@form[:password]} type="password" label="Password" />
        <small>Passwords are NOT stored on the Ptah.sh servers.</small>
        <small>
          Sensitive data is transfered directly to an Agent instances and stored in secrets/configs.
        </small>
        <:actions>
          <.button phx-disable-with="Saving...">Save Docker registry</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{docker_registry: docker_registry} = assigns, socket) do
    changeset = DockerRegistries.change_docker_registry(docker_registry)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"docker_registry" => docker_registry_params}, socket) do
    changeset =
      socket.assigns.docker_registry
      |> DockerRegistries.change_docker_registry(docker_registry_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"docker_registry" => docker_registry_params}, socket) do
    save_docker_registry(socket, socket.assigns.action, docker_registry_params)
  end

  # TODO: implement update for registry credentials
  # defp save_docker_registry(socket, :edit, docker_registry_params) do
  #   case DockerRegistries.update_docker_registry(
  #          socket.assigns.docker_registry,
  #          docker_registry_params
  #        ) do
  #     {:ok, docker_registry} ->
  #       notify_parent({:saved, docker_registry})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Docker registry updated successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  defp save_docker_registry(socket, :new, docker_registry_params) do
    {:ok, docker_config} =
      DockerConfigs.create_docker_config(%{
        name:
          "registry-credentials-#{docker_registry_params["swarm_id"]}-#{docker_registry_params["name"]}",
        swarm_id: docker_registry_params["swarm_id"]
      })

    docker_registry_params = Map.put(docker_registry_params, "config_id", docker_config.id)

    case DockerRegistries.create_docker_registry(docker_registry_params) do
      {:ok, docker_registry} ->
        notify_parent({:saved, docker_registry})

        Presence.docker_config_create(docker_config, %{
          username: docker_registry.username,
          password: docker_registry.password,
          serveraddress: docker_registry.endpoint
        })

        {:noreply,
         socket
         |> put_flash(:info, "Docker registry created successfully")
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
