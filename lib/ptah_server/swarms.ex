defmodule PtahServer.Swarms do
  @moduledoc """
  The Swarms context.
  """

  import Ecto.Query, warn: false
  alias PtahServer.Marketplace
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
  def get_swarm!(id), do: Repo.get!(Swarm, id)

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

  # TODO: add default handler to return 404 instead of 200 for non-matched routes.
  def rebuild_caddy(%Swarm{} = swarm) do
    servers =
      Enum.map(Repo.preload(swarm, :stacks, skip_team_id: true).stacks, fn stack ->
        Enum.map(Repo.preload(stack, :services, skip_team_id: true).services, fn service ->
          map_service_to_caddy(service, stack.name)
        end)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, &Map.merge/2)

    %{
      "apps" => %{
        "http" => %{
          "servers" =>
            Map.keys(servers)
            |> Enum.reduce(%{}, fn port, acc ->
              Map.put(acc, "listen_#{port}", %{
                "listen" => ["0.0.0.0:#{port}"],
                "routes" => servers[port]
              })
            end)
        }
      }
    }
  end

  defp map_service_to_caddy(service, stack_name) do
    ports =
      service.spec.endpoint_spec.ports
      |> Enum.filter(& &1.caddy.enabled)

    if length(ports) == 0 do
      %{}
    else
      Enum.reduce(ports, %{}, fn port, acc ->
        container_port =
          Marketplace.get_stack(
            Repo.preload(service, :stack, skip_team_id: true).stack.stack_name
          )
          |> Marketplace.Stack.get_service(service.service_name)
          |> Marketplace.Stack.Service.get_port(port.name)

        Map.put(
          acc,
          port.caddy.port,
          (acc[port] || []) ++
            [
              %{
                "match" => [
                  %{
                    "host" => [
                      port.caddy.domain
                    ],
                    "path" => [
                      port.caddy.path
                    ]
                  }
                ],
                "handle" => [
                  %{
                    "handler" => "reverse_proxy",
                    "upstreams" => [
                      %{
                        "dial" =>
                          "#{service.service_name}.#{stack_name}:#{container_port["target"]}"
                      }
                    ]
                  }
                ]
              }
            ]
        )
      end)
    end
  end
end
