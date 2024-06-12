defmodule PtahServer.Stacks do
  @moduledoc """
  The Stacks context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias PtahServer.Swarms
  alias PtahServerWeb.Presence
  alias PtahServer.Repo

  alias PtahServer.Stacks.Stack

  @doc """
  Returns the list of stacks.

  ## Examples

      iex> list_stacks()
      [%Stack{}, ...]

  """
  def list_stacks do
    Repo.all(Stack)
  end

  @doc """
  Gets a single stack.

  Raises `Ecto.NoResultsError` if the Stack does not exist.

  ## Examples

      iex> get_stack!(123)
      %Stack{}

      iex> get_stack!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stack!(id), do: Repo.get!(Stack, id)

  @doc """
  Creates a stack.

  ## Examples

      iex> create_stack(%{field: value})
      {:ok, %Stack{}}

      iex> create_stack(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stack(attrs \\ %{}) do
    %Stack{}
    |> Stack.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a stack.

  ## Examples

      iex> update_stack(stack, %{field: new_value})
      {:ok, %Stack{}}

      iex> update_stack(stack, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stack(%Stack{} = stack, attrs) do
    changeset =
      stack
      |> Stack.changeset(attrs)

    old_services_ids = stack.services |> Enum.map(& &1.id)

    updated_services_ids =
      Ecto.Changeset.get_field(changeset, :services)
      |> Enum.filter(&(&1.id != nil))
      |> Enum.map(& &1.id)

    removed_services_ids = old_services_ids -- updated_services_ids

    updated_services =
      Ecto.Changeset.get_field(changeset, :services)
      |> Enum.filter(&(&1.id in updated_services_ids))

    removed_services = stack.services |> Enum.filter(&(&1.id in removed_services_ids))

    case Repo.update(changeset) do
      {:ok, stack} ->
        swarm = Repo.preload(stack, :swarm).swarm

        new_services = stack.services |> Enum.filter(&(&1.id not in old_services_ids))

        Enum.each(removed_services, fn service ->
          Presence.service_delete(swarm, service)
        end)

        Enum.each(updated_services, fn service ->
          Presence.service_update(service)
        end)

        Enum.each(new_services, fn service ->
          Presence.service_create(service)
        end)

        Swarms.rebuild_caddy(Repo.preload(stack, :swarm).swarm)

        {:ok, stack}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a stack.

  ## Examples

      iex> delete_stack(stack)
      {:ok, %Stack{}}

      iex> delete_stack(stack)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stack(%Stack{} = stack) do
    services = Repo.preload(stack, :services).services
    swarm = Repo.preload(stack, :swarm).swarm

    case Repo.delete(stack) do
      {:ok, stack} ->
        for service <- services do
          Presence.service_delete(swarm, service)
        end

        Swarms.rebuild_caddy(Repo.preload(stack, :swarm).swarm)

        {:ok, stack}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stack changes.

  ## Examples

      iex> change_stack(stack)
      %Ecto.Changeset{data: %Stack{}}

  """
  def change_stack(%Stack{} = stack, attrs \\ %{}) do
    Stack.changeset(stack, attrs)
  end
end
