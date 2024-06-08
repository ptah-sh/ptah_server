defmodule PtahServer.DockerRegistriesTest do
  use PtahServer.DataCase

  alias PtahServer.DockerRegistries

  describe "docker_registries" do
    alias PtahServer.DockerRegistries.DockerRegistry

    import PtahServer.DockerRegistriesFixtures

    @invalid_attrs %{name: nil}

    test "list_docker_registries/0 returns all docker_registries" do
      docker_registry = docker_registry_fixture()
      assert DockerRegistries.list_docker_registries() == [docker_registry]
    end

    test "get_docker_registry!/1 returns the docker_registry with given id" do
      docker_registry = docker_registry_fixture()
      assert DockerRegistries.get_docker_registry!(docker_registry.id) == docker_registry
    end

    test "create_docker_registry/1 with valid data creates a docker_registry" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %DockerRegistry{} = docker_registry} = DockerRegistries.create_docker_registry(valid_attrs)
      assert docker_registry.name == "some name"
    end

    test "create_docker_registry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DockerRegistries.create_docker_registry(@invalid_attrs)
    end

    test "update_docker_registry/2 with valid data updates the docker_registry" do
      docker_registry = docker_registry_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %DockerRegistry{} = docker_registry} = DockerRegistries.update_docker_registry(docker_registry, update_attrs)
      assert docker_registry.name == "some updated name"
    end

    test "update_docker_registry/2 with invalid data returns error changeset" do
      docker_registry = docker_registry_fixture()
      assert {:error, %Ecto.Changeset{}} = DockerRegistries.update_docker_registry(docker_registry, @invalid_attrs)
      assert docker_registry == DockerRegistries.get_docker_registry!(docker_registry.id)
    end

    test "delete_docker_registry/1 deletes the docker_registry" do
      docker_registry = docker_registry_fixture()
      assert {:ok, %DockerRegistry{}} = DockerRegistries.delete_docker_registry(docker_registry)
      assert_raise Ecto.NoResultsError, fn -> DockerRegistries.get_docker_registry!(docker_registry.id) end
    end

    test "change_docker_registry/1 returns a docker_registry changeset" do
      docker_registry = docker_registry_fixture()
      assert %Ecto.Changeset{} = DockerRegistries.change_docker_registry(docker_registry)
    end
  end
end
