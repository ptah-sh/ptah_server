defmodule PtahServer.SwarmsTest do
  use PtahServer.DataCase

  alias PtahServer.Swarms

  describe "swarms" do
    alias PtahServer.Swarms.Swarm

    import PtahServer.SwarmsFixtures

    @invalid_attrs %{name: nil, team_id: nil, ext_id: nil}

    test "list_swarms/0 returns all swarms" do
      swarm = swarm_fixture()
      assert Swarms.list_swarms() == [swarm]
    end

    test "get_swarm!/1 returns the swarm with given id" do
      swarm = swarm_fixture()
      assert Swarms.get_swarm!(swarm.id) == swarm
    end

    test "create_swarm/1 with valid data creates a swarm" do
      valid_attrs = %{name: "some name", team_id: 42, ext_id: "some ext_id"}

      assert {:ok, %Swarm{} = swarm} = Swarms.create_swarm(valid_attrs)
      assert swarm.name == "some name"
      assert swarm.team_id == 42
      assert swarm.ext_id == "some ext_id"
    end

    test "create_swarm/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Swarms.create_swarm(@invalid_attrs)
    end

    test "update_swarm/2 with valid data updates the swarm" do
      swarm = swarm_fixture()
      update_attrs = %{name: "some updated name", team_id: 43, ext_id: "some updated ext_id"}

      assert {:ok, %Swarm{} = swarm} = Swarms.update_swarm(swarm, update_attrs)
      assert swarm.name == "some updated name"
      assert swarm.team_id == 43
      assert swarm.ext_id == "some updated ext_id"
    end

    test "update_swarm/2 with invalid data returns error changeset" do
      swarm = swarm_fixture()
      assert {:error, %Ecto.Changeset{}} = Swarms.update_swarm(swarm, @invalid_attrs)
      assert swarm == Swarms.get_swarm!(swarm.id)
    end

    test "delete_swarm/1 deletes the swarm" do
      swarm = swarm_fixture()
      assert {:ok, %Swarm{}} = Swarms.delete_swarm(swarm)
      assert_raise Ecto.NoResultsError, fn -> Swarms.get_swarm!(swarm.id) end
    end

    test "change_swarm/1 returns a swarm changeset" do
      swarm = swarm_fixture()
      assert %Ecto.Changeset{} = Swarms.change_swarm(swarm)
    end
  end
end
