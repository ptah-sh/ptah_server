defmodule PtahServerWeb.TlsCertLive.FormComponent do
  alias PtahServer.Swarms
  use PtahServerWeb, :live_component

  alias PtahServer.TlsCerts

  @impl true
  def mount(socket) do
    swarms = Enum.map(Swarms.list_swarms(), &{&1.name, &1.id})

    socket =
      socket
      |> assign(:swarms, swarms)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage tls_cert records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tls_cert-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:swarm_id]} type="select" options={@swarms} label="Swarm" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.inputs_for :let={cert_config} field={@form[:cert_config]}>
          <.input
            field={cert_config[:name]}
            type="hidden"
            value={"tls-cert-#{@form[:name].value}-certificate"}
          />

          <.input
            field={cert_config[:swarm_id]}
            type="hidden"
            value={@form[:swarm_id].value || @swarms |> hd() |> elem(1)}
          />

          <.input field={cert_config[:data]} type="textarea" label="Certificate" />
        </.inputs_for>
        <.inputs_for :let={key_secret} field={@form[:key_secret]}>
          <.input
            field={key_secret[:name]}
            type="hidden"
            value={"tls-cert-#{@form[:name].value}-private-key"}
          />

          <.input
            field={key_secret[:swarm_id]}
            type="hidden"
            value={@form[:swarm_id].value || @swarms |> hd() |> elem(1)}
          />

          <.input field={key_secret[:data]} type="textarea" label="Private Key" />
          <small>
            Private Keys are NOT stored on the Ptah.sh servers. Sensitive data is transfered directly to an Agent instances and stored in secrets/configs.
          </small>
        </.inputs_for>

        <:actions>
          <.button phx-disable-with="Saving...">Save TLS cert</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{tls_cert: tls_cert} = assigns, socket) do
    changeset = TlsCerts.change_tls_cert(tls_cert)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"tls_cert" => tls_cert_params}, socket) do
    changeset =
      socket.assigns.tls_cert
      |> TlsCerts.change_tls_cert(tls_cert_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"tls_cert" => tls_cert_params}, socket) do
    save_tls_cert(socket, socket.assigns.action, tls_cert_params)
  end

  defp save_tls_cert(socket, :edit, tls_cert_params) do
    case TlsCerts.update_tls_cert(socket.assigns.tls_cert, tls_cert_params) do
      {:ok, tls_cert} ->
        notify_parent({:saved, tls_cert})

        {:noreply,
         socket
         |> put_flash(:info, "Tls cert updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_tls_cert(socket, :new, tls_cert_params) do
    case TlsCerts.create_tls_cert(tls_cert_params) do
      {:ok, tls_cert} ->
        notify_parent({:saved, tls_cert})

        {:noreply,
         socket
         |> put_flash(:info, "Tls cert created successfully")
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
