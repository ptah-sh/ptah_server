defmodule PtahServerWeb.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, Paths, Server, SecurityScheme}
  alias PtahServerWeb.{Endpoint, Router}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: to_string(Application.spec(:my_app, :description)),
        version: to_string(Application.spec(:my_app, :vsn))
      },
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{
          "team_token" => %SecurityScheme{
            type: "apiKey",
            name: "X-Ptah-Api-Key",
            in: "header",
            description: "Team API token"
          }
        }
      },
      security: [%{"team_token" => []}]
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
