defmodule PtahServer.Services.Service do
  alias PtahServer.Repo
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

    # TODO: extract changesets to maintain better readability
    embeds_one :spec, ServiceSpec, on_replace: :update do
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

      embeds_one :task_template, TaskTemplate, on_replace: :update do
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

        embeds_one :container_spec, ContainerSpec, on_replace: :update do
          def changeset(container_spec, attrs) do
            container_spec
            |> cast(attrs, [:image])
            |> cast_embed(:env, sort_param: :env_sort, drop_param: :env_drop)
            |> cast_embed(:mounts, sort_param: :mounts_sort, drop_param: :mounts_drop)
            |> validate_required([:image])

            #     # |> cast(attrs, [:name, :image, :hostname])
            #     # |> validate_required([:name, :image, :hostname])
          end

          field :image, :string

          embeds_many :env, Env, on_replace: :delete do
            def changeset(env, attrs) do
              env
              |> cast(attrs, [:name, :value])
              |> validate_required([:name, :value])
            end

            field :name, :string
            field :value, :string
          end

          embeds_many :mounts, MountSpec, on_replace: :delete do
            def changeset(mount_spec, attrs) do
              mount_spec
              |> cast(attrs, [:source, :target])
              |> validate_required([:source, :target])
            end

            field :source, :string
            field :target, :string
          end
        end
      end

      embeds_one :endpoint_spec, EndpointSpec do
        def changeset(endpoint_spec, attrs) do
          endpoint_spec
          |> cast(attrs, [])
          |> cast_embed(:ports, sort_param: :ports_sort, drop_param: :ports_drop)
          |> cast_embed(:caddy, sort_param: :caddy_sort, drop_param: :caddy_drop)
        end

        embeds_many :ports, Port, on_replace: :delete do
          def changeset(port, attrs) do
            port
            # TODO: remove name from casts and assign the port name in the form handler
            |> cast(attrs, [:target_port, :published_port])
            |> validate_required([:target_port, :published_port])
          end

          field :target_port, :integer
          field :published_port, :integer
        end

        embeds_many :caddy, CaddyHandler, on_replace: :delete do
          def changeset(caddy, attrs) do
            caddy
            |> cast(attrs, [:target_port, :domain, :published_port, :path])
            |> validate_required([:target_port, :domain, :published_port, :path])
          end

          field :target_port, :integer
          field :domain, :string
          field :published_port, :integer
          field :path, :string
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
  end
end
