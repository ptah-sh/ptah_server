defmodule PtahServerWeb.ServiceDeployController do
  use PtahServerWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias PtahServerWeb.Presence
  alias PtahServer.Repo
  alias PtahServer.Services.Service
  alias PtahServer.Services
  alias PtahServerWeb.Schemas.Service.{DeployParams, DeployResponse}

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["services"]

  operation :create,
    summary: "Deploy service",
    parameters: [
      service_id: [in: :path, description: "The Service ID", type: :integer, example: 1001]
    ],
    request_body: {"Deploy Params", "application/json", DeployParams},
    responses: [
      ok: {"Deploy Response", "application/json", DeployResponse}
    ]

  def create(conn, %{service_id: service_id} = _params) do
    service = PtahServer.Services.get_service!(service_id)

    service
    |> Services.change_service(merge_spec(service.spec, conn.body_params.spec))
    |> Repo.update!()
    |> Presence.service_update()

    json(conn, %{})
  end

  def merge_spec(%Service.ServiceSpec{} = spec, params) do
    %{
      "spec" => %{
        "task_template" => %{
          "container_spec" => %{
            "image" => params.task_template.container_spec.image,
            # TODO: filter out duplicated env?
            "env" =>
              Enum.map(spec.task_template.container_spec.env, &Map.from_struct/1) ++
                (params.task_template.container_spec.env || [])
          }
        }
      }
    }
  end
end
