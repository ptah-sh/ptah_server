defmodule PtahServer.Swarms do
  @moduledoc """
  The Swarms context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias PtahServer.Services.Service
  alias PtahServer.Services
  alias PtahServer.Swarms
  alias PtahServerWeb.Presence
  alias PtahServer.Repo

  alias PtahServer.Swarms.Swarm

  @doc """
  Returns the list of swarms.

  ## Examples

      iex> list_swarms()
      [%Swarm{}, ...]

  """
  def list_swarms do
    Repo.all(Swarm)
  end

  @doc """
  Gets a single swarm.

  Raises `Ecto.NoResultsError` if the Swarm does not exist.

  ## Examples

      iex> get_swarm!(123)
      %Swarm{}

      iex> get_swarm!(456)
      ** (Ecto.NoResultsError)

  """
  def get_swarm!(id, opts \\ []), do: Repo.get!(Swarm, id, opts)

  @doc """
  Creates a swarm.

  ## Examples

      iex> create_swarm(%{field: value})
      {:ok, %Swarm{}}

      iex> create_swarm(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_swarm(attrs \\ %{}) do
    %Swarm{}
    |> Swarm.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a swarm.

  ## Examples

      iex> update_swarm(swarm, %{field: new_value})
      {:ok, %Swarm{}}

      iex> update_swarm(swarm, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_swarm(%Swarm{} = swarm, attrs) do
    swarm
    |> Swarm.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a swarm.

  ## Examples

      iex> delete_swarm(swarm)
      {:ok, %Swarm{}}

      iex> delete_swarm(swarm)
      {:error, %Ecto.Changeset{}}

  """
  def delete_swarm(%Swarm{} = swarm) do
    Repo.delete(swarm)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking swarm changes.

  ## Examples

      iex> change_swarm(swarm)
      %Ecto.Changeset{data: %Swarm{}}

  """
  def change_swarm(%Swarm{} = swarm, attrs \\ %{}) do
    Swarm.changeset(swarm, attrs)
  end

  def list_tls_certs(swarm) do
    Repo.preload(swarm, tls_certs: [:cert_config, :key_secret]).tls_certs
    |> Enum.filter(fn tls_cert -> tls_cert.cert_config.ext_id != nil end)
    |> Enum.filter(fn tls_cert -> tls_cert.key_secret.ext_id != nil end)
  end

  # TODO: add default handler to return 404 instead of 200 for non-matched routes.
  def rebuild_caddy(%Swarm{} = swarm) do
    caddy = Services.get_caddy!(swarm)

    tls_certs = list_tls_certs(swarm)

    {:ok, caddy} =
      Services.change_service(caddy, %{
        "spec" => %{
          "task_template" => %{
            "container_spec" => %{
              "secrets" =>
                (Enum.map(caddy.spec.task_template.container_spec.secrets, &Map.from_struct/1) ++
                   Enum.map(tls_certs, fn tls_cert ->
                     %{
                       target: "/ptah/caddy/tls/#{tls_cert.name}.key",
                       secret_id: tls_cert.key_secret_id
                     }
                   end))
                |> Enum.uniq_by(fn secret -> secret.target end),
              "configs" =>
                (Enum.map(caddy.spec.task_template.container_spec.configs, &Map.from_struct/1) ++
                   Enum.map(tls_certs, fn tls_cert ->
                     %{
                       target: "/ptah/caddy/tls/#{tls_cert.name}.crt",
                       config_id: tls_cert.cert_config_id
                     }
                   end))
                |> Enum.uniq_by(fn config -> config.target end)
            }
          }
        }
      })
      |> Repo.update()

    Presence.service_update(caddy)
  end

  def load_caddy_config(swarm) do
    tls_certs = list_tls_certs(swarm)

    servers =
      Enum.map(Repo.preload(swarm, :stacks, skip_team_id: true).stacks, fn stack ->
        Enum.map(Repo.preload(stack, :services, skip_team_id: true).services, fn service ->
          map_service_to_caddy(service, stack.name)
        end)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, fn caddy, acc ->
        Map.to_list(caddy)
        |> Enum.reduce(acc, fn {k, v}, acc ->
          Map.update(acc, k, v, fn current -> current ++ v end)
        end)
      end)

    config = %{
      "apps" => %{
        "tls" => %{
          "certificates" => %{
            # "load_files" => map_tls_certs(tls_certs)
            "load_folders" => [
              "/ptah/caddy/tls"
            ]
          }
        },
        "http" => %{
          "servers" =>
            Map.keys(servers)
            |> Enum.reduce(%{}, fn port, acc ->
              Map.put(acc, "listen_#{port}", %{
                "listen" => ["0.0.0.0:#{port}"],
                "routes" => sort_caddy_routes(servers[port])
              })
            end)
        }
      }
    }

    Presence.load_caddy(swarm, config)
  end

  defp map_service_to_caddy(service, stack_name) do
    caddy = service.spec.endpoint_spec.caddy

    if length(caddy) == 0 do
      %{}
    else
      Enum.reduce(caddy, %{}, fn caddy, acc ->
        Map.put(
          acc,
          caddy.published_port,
          (acc[caddy.published_port] || []) ++
            [
              %{
                "match" => [
                  %{
                    "host" => [
                      caddy.domain
                    ],
                    "path" => [
                      caddy.path
                    ]
                  }
                ],
                "handle" => [
                  %{
                    "handler" => "reverse_proxy",
                    "transport" => get_transport_for_caddy(caddy),
                    "upstreams" => [
                      %{
                        "dial" => "#{service.name}.#{stack_name}:#{caddy.target_port}"
                      }
                    ],
                    "headers" => get_headers_for_port(caddy.published_port, caddy.domain)
                  }
                ]
              }
            ]
        )
      end)
    end
  end

  defp sort_caddy_routes(routes) do
    Enum.sort_by(routes, &get_route_weight/1, :desc)
  end

  defp get_route_weight(route) do
    segments =
      Enum.at(route["match"], 0)["path"]
      |> Enum.at(0)
      |> String.split("*")

    {
      # Specificality
      Enum.join(segments, "") |> String.length(),
      # Wildcards count, (N * -1) to sort in descending order
      (length(segments) - 1) * -1
    }
  end

  defp get_headers_for_port(443, host) do
    %{
      "request" => %{
        "set" => %{
          "x-forwarded-proto" => ["https"],
          "x-forwarded-schema" => ["https"],
          "x-forwarded-port" => ["443"],
          "x-forwarded-host" => [host]
        }
      }
    }
  end

  defp get_headers_for_port(_port, _host) do
    %{}
  end

  defp get_transport_for_caddy(caddy) do
    case caddy.transport_protocol do
      :http -> get_transport(:http, caddy.transport_http)
      :fastcgi -> get_transport(:fastcgi, caddy.transport_fastcgi)
    end
  end

  defp get_transport(:http, _transport) do
    %{
      "protocol" => "http"
    }
  end

  defp get_transport(:fastcgi, transport) do
    %{
      "protocol" => "fastcgi",
      "root" => transport.root,
      # "env" => %{
      #   "SCRIPT_FILENAME" => "/app/public/index.php"
      # }
      "env" =>
        Enum.reduce(transport.env, %{}, fn env, acc -> Map.put(acc, env.name, env.value) end)
    }
  end

  defp get_transport(_, _) do
    %{
      "protocol" => "http"
    }
  end

  # https://caddyserver.com/docs/json/apps/tls/certificates/load_files/
  defp map_tls_certs(certs) do
    Enum.reduce(certs, [], fn cert, acc ->
      acc ++
        [
          %{
            certificate: "/ptah/caddy/tls/#{cert.name}.crt",
            key: "/ptah/caddy/tls/#{cert.name}.key",
            format: "pem"
          }
        ]
    end)
  end
end
