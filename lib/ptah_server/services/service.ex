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

    embeds_one :spec, ServiceSpec do
      def changeset(service_spec, attrs) do
        service_spec
        |> cast(attrs, [:bind_volumes, :placement_server_id])
        |> cast_embed(:endpoint_spec)
        |> cast_embed(:task_template)
        |> validate_required_server_if_volumes_bound()
      end

      def validate_required_server_if_volumes_bound(changeset) do
        if get_field(changeset, :bind_volumes) do
          validate_required(changeset, [:placement_server_id])
        else
          changeset
        end
      end

      field :bind_volumes, :boolean
      field :placement_server_id, :integer

      embeds_one :task_template, TaskTemplate do
        def changeset(task_template, attrs) do
          task_template
          |> cast(attrs, [])
          |> cast_embed(:container_spec)

          # |> cast_embed(:placement)
          # |> cast_embed(:networks)
        end

        # embeds_one :placement, Placement do
        #   def changeset(placement, attrs) do
        #     placement
        #     |> cast(attrs, [:constraints])
        #   end

        #   field :constraints, {:array, :string}
        # end

        embeds_one :container_spec, ContainerSpec do
          def changeset(container_spec, attrs) do
            container_spec
            |> cast(attrs, [])
            |> cast_embed(:mounts)

            #     # |> cast(attrs, [:name, :image, :hostname])
            #     # |> validate_required([:name, :image, :hostname])
          end

          embeds_many :mounts, MountSpec do
            def changeset(mount_spec, attrs) do
              mount_spec
              |> cast(attrs, [:name])
              |> validate_required([:name])
            end

            field :name, :string
          end
        end
      end

      embeds_one :endpoint_spec, EndpointSpec do
        def changeset(endpoint_spec, attrs) do
          endpoint_spec
          |> cast(attrs, [])
          |> cast_embed(:ports)
        end

        embeds_many :ports, Port do
          field :name, :string

          def changeset(port, attrs) do
            port
            # TODO: remove name from casts and assign the port name in the form handler
            |> cast(attrs, [:name])
            |> validate_required([:name])
            |> cast_embed(:docker)
            |> cast_embed(:caddy)
          end

          embeds_one :docker, Docker do
            field :exposed, :boolean
            field :published_port, :integer

            def changeset(docker, attrs) do
              docker
              |> cast(attrs, [:exposed, :published_port])
              |> validate_required([:exposed])
              |> validate_required_if_exposed()
            end

            def validate_required_if_exposed(changeset) do
              case get_field(changeset, :exposed) do
                true -> validate_required(changeset, [:published_port])
                _ -> changeset
              end
            end
          end

          embeds_one :caddy, Caddy do
            def changeset(caddy, attrs) do
              caddy
              |> cast(attrs, [:enabled, :domain, :port, :path])
              |> validate_required([:enabled])
              |> validate_required_if_enabled()
            end

            def validate_required_if_enabled(changeset) do
              case get_field(changeset, :enabled) do
                true -> validate_required(changeset, [:domain, :port, :path])
                _ -> changeset
              end
            end

            field :enabled, :boolean
            field :domain, :string
            field :port, :integer
            field :path, :string
          end
        end
      end
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :service_name, :ext_id])
    |> cast_embed(:spec, with: &PtahServer.Services.Service.ServiceSpec.changeset/2)
    # |> cast_embed(:published_ports, with: &published_port_changeset/2)
    |> validate_required([:name, :service_name])
    |> maybe_put_team_id()

    # TODO: make prepare_changes(&remove_unpublished_ports/1) ???
  end
end
