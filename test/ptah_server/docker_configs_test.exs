defmodule PtahServer.DockerConfigsTest do
  use PtahServer.DataCase

  alias PtahServer.DockerConfigs

  describe "docker_configs" do
    alias PtahServer.DockerConfigs.DockerConfig

    import PtahServer.DockerConfigsFixtures

    @invalid_attrs %{name: nil, ext_id: nil}

    test "list_docker_configs/0 returns all docker_configs" do
      docker_config = docker_config_fixture()
      assert DockerConfigs.list_docker_configs() == [docker_config]
    end

    test "get_docker_config!/1 returns the docker_config with given id" do
      docker_config = docker_config_fixture()
      assert DockerConfigs.get_docker_config!(docker_config.id) == docker_config
    end

    test "create_docker_config/1 with valid data creates a docker_config" do
      valid_attrs = %{name: "some name", ext_id: "some ext_id"}

      assert {:ok, %DockerConfig{} = docker_config} = DockerConfigs.create_docker_config(valid_attrs)
      assert docker_config.name == "some name"
      assert docker_config.ext_id == "some ext_id"
    end

    test "create_docker_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DockerConfigs.create_docker_config(@invalid_attrs)
    end

    test "update_docker_config/2 with valid data updates the docker_config" do
      docker_config = docker_config_fixture()
      update_attrs = %{name: "some updated name", ext_id: "some updated ext_id"}

      assert {:ok, %DockerConfig{} = docker_config} = DockerConfigs.update_docker_config(docker_config, update_attrs)
      assert docker_config.name == "some updated name"
      assert docker_config.ext_id == "some updated ext_id"
    end

    test "update_docker_config/2 with invalid data returns error changeset" do
      docker_config = docker_config_fixture()
      assert {:error, %Ecto.Changeset{}} = DockerConfigs.update_docker_config(docker_config, @invalid_attrs)
      assert docker_config == DockerConfigs.get_docker_config!(docker_config.id)
    end

    test "delete_docker_config/1 deletes the docker_config" do
      docker_config = docker_config_fixture()
      assert {:ok, %DockerConfig{}} = DockerConfigs.delete_docker_config(docker_config)
      assert_raise Ecto.NoResultsError, fn -> DockerConfigs.get_docker_config!(docker_config.id) end
    end

    test "change_docker_config/1 returns a docker_config changeset" do
      docker_config = docker_config_fixture()
      assert %Ecto.Changeset{} = DockerConfigs.change_docker_config(docker_config)
    end
  end
end
