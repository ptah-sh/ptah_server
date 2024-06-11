defmodule PtahServerWeb.SwarmLive.FormComponent do
  defmodule NewSwarm do
    use Ecto.Schema

    import Ecto.Changeset

    embedded_schema do
      field :name, :string
      field :advertise_addr, :string
    end

    def changeset(swarm, attrs \\ %{}) do
      swarm
      |> cast(attrs, [:name, :advertise_addr])
      |> validate_required([:name, :advertise_addr])
    end
  end

  require Logger
  alias PtahServerWeb.Presence
  use PtahServerWeb, :live_component

  alias PtahServer.Swarms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage swarm records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="swarm-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Swarm Name" />

        <.input
          field={@form[:advertise_addr]}
          type="select"
          options={@addresses}
          label="Advertise Address"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Initialize Swarm</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{server: server} = assigns, socket) do
    changeset = NewSwarm.changeset(%NewSwarm{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :addresses,
       server.networks
       |> Enum.map(&{&1.name, &1.ips |> Enum.map(fn ip -> {ip.address, ip.address} end)})
     )
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"new_swarm" => swarm_params}, socket) do
    changeset =
      %NewSwarm{}
      |> NewSwarm.changeset(swarm_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"new_swarm" => swarm_params}, socket) do
    save_swarm(socket, socket.assigns.action, swarm_params)
  end

  # defp save_swarm(socket, :edit, swarm_params) do
  #   case Swarms.update_swarm(socket.assigns.swarm, swarm_params) do
  #     {:ok, swarm} ->
  #       notify_parent({:saved, swarm})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Swarm updated successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  defp save_swarm(socket, :new, swarm_params) do
    changeset = %NewSwarm{} |> NewSwarm.changeset(swarm_params)

    if changeset.valid? do
      case Swarms.create_swarm(%{name: swarm_params["name"]}) do
        {:ok, swarm} ->
          notify_parent({:saved, swarm})

          params =
            case :os.type() do
              # TODO: find a better way to initialize swarm on Mac?
              # TODO: check os of the Agent's host, not the server's host.
              {:unix, :darwin} ->
                %{
                  listen_addr: "0.0.0.0:2377",
                  advertise_addr: "127.0.0.1:2377"
                }

              _ ->
                %{
                  listen_addr: "0.0.0.0:2377",
                  advertise_addr: swarm_params["advertise_addr"]
                }
            end

          Presence.swarm_init(socket.assigns.server, swarm, params)

          {:noreply,
           socket
           |> put_flash(:info, "Swarm created successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    else
      {:noreply,
       assign_form(
         socket,
         changeset
         |> Map.put(:action, :validate)
       )}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
