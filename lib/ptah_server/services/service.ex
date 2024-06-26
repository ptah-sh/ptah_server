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

    # TODO: extract changesets to maintain better readability
    embeds_one :spec, ServiceSpec, on_replace: :update do
      def changeset(service_spec, attrs) do
        service_spec
        |> cast(attrs, [:bind_volumes, :placement_server_id])
        |> cast_embed(:endpoint_spec, required: true)
        |> cast_embed(:task_template, required: true)
        |> cast_embed(:mode, required: true)
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
          |> cast_embed(:container_spec, required: true)

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
            |> cast(attrs, [:docker_registry_id, :image])
            |> cast_embed(:env, sort_param: :env_sort, drop_param: :env_drop)
            |> cast_embed(:mounts, sort_param: :mounts_sort, drop_param: :mounts_drop)
            |> validate_required([:image])

            #     # |> cast(attrs, [:name, :image, :hostname])
            #     # |> validate_required([:name, :image, :hostname])
          end

          field :image, :string

          belongs_to :docker_registry, PtahServer.DockerRegistries.DockerRegistry

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
              |> cast(attrs, [:name, :target])
              |> validate_required([:name, :target])
            end

            field :name, :string
            field :target, :string
          end
        end
      end

      embeds_one :mode, Mode, on_replace: :update do
        def changeset(mode, attrs) do
          mode
          |> cast(attrs, [])
          |> cast_embed(:replicated, required: true)
        end

        embeds_one :replicated, Replicated, on_replace: :update do
          def changeset(replicated, attrs) do
            replicated
            |> cast(attrs, [:replicas])
            |> validate_required([:replicas])
            |> validate_number(:replicas, greater_than_or_equal_to: 0)
          end

          field :replicas, :integer
        end
      end

      embeds_one :endpoint_spec, EndpointSpec, on_replace: :update do
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
            |> cast(attrs, [:transport_protocol, :target_port, :domain, :published_port, :path])
            |> cast_embed(:transport_http)
            |> cast_embed(:transport_fastcgi)
            |> validate_required([
              :transport_protocol,
              :target_port,
              :domain,
              :published_port,
              :path
            ])
          end

          field :transport_protocol, Ecto.Enum, values: [:http, :fastcgi]
          field :target_port, :integer
          field :domain, :string
          field :published_port, :integer
          field :path, :string

          embeds_one :transport_http, HttpTransport, on_replace: :update do
          end

          embeds_one :transport_fastcgi, FastcgiTransport, on_replace: :update do
            def changeset(fastcgi, attrs) do
              fastcgi
              |> cast(attrs, [:root])
              |> validate_required([:root])
              |> cast_embed(:env, sort_param: :env_sort, drop_param: :env_drop)
            end

            field :root, :string

            embeds_many :env, Env, on_replace: :delete do
              def changeset(env, attrs) do
                env
                |> cast(attrs, [:name, :value])
                |> validate_required([:name, :value])
              end

              field :name, :string
              field :value, :string
            end
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
    |> cast_embed(:spec,
      with: &PtahServer.Services.Service.ServiceSpec.changeset/2,
      required: true
    )
    |> validate_required([:name])
    |> maybe_put_team_id()
  end
end
