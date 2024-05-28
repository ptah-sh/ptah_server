defmodule PtahServer.Swarms do
  @moduledoc """
  The Swarms context.
  """

  import Ecto.Query, warn: false
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
end
