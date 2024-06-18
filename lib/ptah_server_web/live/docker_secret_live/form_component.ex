defmodule PtahServerWeb.DockerSecretLive.FormComponent do
  use PtahServerWeb, :live_component

  alias PtahServer.DockerSecrets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage docker_secret records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="docker_secret-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:ext_id]} type="text" label="Ext" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Docker secret</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{docker_secret: docker_secret} = assigns, socket) do
    changeset = DockerSecrets.change_docker_secret(docker_secret)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"docker_secret" => docker_secret_params}, socket) do
    changeset =
      socket.assigns.docker_secret
      |> DockerSecrets.change_docker_secret(docker_secret_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"docker_secret" => docker_secret_params}, socket) do
    save_docker_secret(socket, socket.assigns.action, docker_secret_params)
  end

  defp save_docker_secret(socket, :edit, docker_secret_params) do
    case DockerSecrets.update_docker_secret(socket.assigns.docker_secret, docker_secret_params) do
      {:ok, docker_secret} ->
        notify_parent({:saved, docker_secret})

        {:noreply,
         socket
         |> put_flash(:info, "Docker secret updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_docker_secret(socket, :new, docker_secret_params) do
    case DockerSecrets.create_docker_secret(docker_secret_params) do
      {:ok, docker_secret} ->
        notify_parent({:saved, docker_secret})

        {:noreply,
         socket
         |> put_flash(:info, "Docker secret created successfully")
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
