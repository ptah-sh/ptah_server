defmodule PtahServerWeb.Schemas.Service do
  alias OpenApiSpex.Schema

  require OpenApiSpex

  defmodule DeployParams do
    OpenApiSpex.schema(%{
      title: "DeployParams",
      description: "Deploy params",
      type: :object,
      properties: %{
        spec: %Schema{
          type: :object,
          properties: %{
            task_template: %Schema{
              type: :object,
              properties: %{
                container_spec: %Schema{
                  type: :object,
                  properties: %{
                    image: %Schema{
                      type: :string
                    },
                    env: %Schema{
                      type: :array,
                      items: %Schema{
                        type: :object,
                        properties: %{
                          name: %Schema{
                            type: :string
                          },
                          value: %Schema{
                            type: :string
                          }
                        },
                        required: [:name, :value]
                      }
                    }
                  },
                  required: [:image]
                }
              },
              required: [:container_spec]
            }
          },
          required: [:task_template]
        }
      },
      required: [:spec]
    })
  end

  defmodule DeployResponse do
    OpenApiSpex.schema(%{
      title: "DeployResponse",
      description: "Deploy response",
      type: :object,
      properties: %{}
    })
  end
end
