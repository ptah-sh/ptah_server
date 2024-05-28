defmodule PtahServer.Services.Service do
  use Ecto.Schema
  import Ecto.Changeset

  schema "services" do
    field :name, :string
    field :team_id, :integer
    field :ext_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:team_id, :name, :ext_id])
    |> validate_required([:team_id, :name, :ext_id])
  end
end
