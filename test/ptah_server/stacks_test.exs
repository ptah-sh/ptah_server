defmodule PtahServer.StacksTest do
  use PtahServer.DataCase

  alias PtahServer.Stacks

  describe "stacks" do
    alias PtahServer.Stacks.Stack

    import PtahServer.StacksFixtures

    @invalid_attrs %{name: nil, team_id: nil, stack_name: nil, stack_version: nil}

    test "list_stacks/0 returns all stacks" do
      stack = stack_fixture()
      assert Stacks.list_stacks() == [stack]
    end

    test "get_stack!/1 returns the stack with given id" do
      stack = stack_fixture()
      assert Stacks.get_stack!(stack.id) == stack
    end

    test "create_stack/1 with valid data creates a stack" do
      valid_attrs = %{name: "some name", team_id: 42, stack_name: "some stack_name", stack_version: "some stack_version"}

      assert {:ok, %Stack{} = stack} = Stacks.create_stack(valid_attrs)
      assert stack.name == "some name"
      assert stack.team_id == 42
      assert stack.stack_name == "some stack_name"
      assert stack.stack_version == "some stack_version"
    end

    test "create_stack/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stacks.create_stack(@invalid_attrs)
    end

    test "update_stack/2 with valid data updates the stack" do
      stack = stack_fixture()
      update_attrs = %{name: "some updated name", team_id: 43, stack_name: "some updated stack_name", stack_version: "some updated stack_version"}

      assert {:ok, %Stack{} = stack} = Stacks.update_stack(stack, update_attrs)
      assert stack.name == "some updated name"
      assert stack.team_id == 43
      assert stack.stack_name == "some updated stack_name"
      assert stack.stack_version == "some updated stack_version"
    end

    test "update_stack/2 with invalid data returns error changeset" do
      stack = stack_fixture()
      assert {:error, %Ecto.Changeset{}} = Stacks.update_stack(stack, @invalid_attrs)
      assert stack == Stacks.get_stack!(stack.id)
    end

    test "delete_stack/1 deletes the stack" do
      stack = stack_fixture()
      assert {:ok, %Stack{}} = Stacks.delete_stack(stack)
      assert_raise Ecto.NoResultsError, fn -> Stacks.get_stack!(stack.id) end
    end

    test "change_stack/1 returns a stack changeset" do
      stack = stack_fixture()
      assert %Ecto.Changeset{} = Stacks.change_stack(stack)
    end
  end
end
