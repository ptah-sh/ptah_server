defmodule PtahServer.Stacks do
  @moduledoc """
  The Stacks context.
  """

  import Ecto.Query, warn: false
  require Logger
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
    |> Ecto.Changeset.put_change(:team_id, Repo.get_team_id())
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
    stack
    |> Stack.changeset(attrs)
    |> Repo.update()
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
    Repo.delete(stack)
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
