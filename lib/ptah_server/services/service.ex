defmodule PtahServer.Services.Service do
  require Logger
  use Ecto.Schema
  import Ecto.Changeset

  schema "services" do
    field :name, :string
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
    |> cast(attrs, [:name, :ext_id])
    |> cast_embed(:published_ports, with: &published_port_changeset/2)
    |> validate_required([:name])
    |> prepare_changes(&maybe_put_team_id/1)

    # TODO: make prepare_changes(&remove_unpublished_ports/1) ???
  end

  def published_port_changeset(port, attrs) do
    port
    |> cast(attrs, [:published_port])
    |> validate_required([:published_port])
  end

  # TODO: Move to generic changeset module
  defp maybe_put_team_id(changeset) do
    Logger.debug(
      "PUT TEAM ID: #{inspect({get_change(changeset, :team_id), changeset.repo.get_team_id()})}"
    )

    if get_change(changeset, :team_id) == nil do
      put_change(changeset, :team_id, changeset.repo.get_team_id())
    else
      changeset
    end
  end
end
