defmodule PtahServerWeb.DockerConfigLive.FormComponent do
  use PtahServerWeb, :live_component

  alias PtahServer.DockerConfigs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage docker_config records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="docker_config-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:ext_id]} type="text" label="Ext" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Docker config</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{docker_config: docker_config} = assigns, socket) do
    changeset = DockerConfigs.change_docker_config(docker_config)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"docker_config" => docker_config_params}, socket) do
    changeset =
      socket.assigns.docker_config
      |> DockerConfigs.change_docker_config(docker_config_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"docker_config" => docker_config_params}, socket) do
    save_docker_config(socket, socket.assigns.action, docker_config_params)
  end

  defp save_docker_config(socket, :edit, docker_config_params) do
    case DockerConfigs.update_docker_config(socket.assigns.docker_config, docker_config_params) do
      {:ok, docker_config} ->
        notify_parent({:saved, docker_config})

        {:noreply,
         socket
         |> put_flash(:info, "Docker config updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_docker_config(socket, :new, docker_config_params) do
    case DockerConfigs.create_docker_config(docker_config_params) do
      {:ok, docker_config} ->
        notify_parent({:saved, docker_config})

        {:noreply,
         socket
         |> put_flash(:info, "Docker config created successfully")
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
