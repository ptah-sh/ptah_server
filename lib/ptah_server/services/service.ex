defmodule PtahServer.Services.Service do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "services" do
    field :name, :string
    field :service_name, :string
    field :ext_id, :string, default: ""

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :stack, PtahServer.Stacks.Stack

    embeds_many :published_ports, ServicePort, on_replace: :delete do
      field :name, :string
      field :published_port, :integer
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :service_name, :ext_id])
    |> cast_embed(:published_ports, with: &published_port_changeset/2)
    |> validate_required([:name, :service_name])
    |> maybe_put_team_id()

    # TODO: make prepare_changes(&remove_unpublished_ports/1) ???
  end

  def published_port_changeset(port, attrs) do
    port
    |> cast(attrs, [:name, :published_port])
    |> validate_required([:name, :published_port])
  end
end
