defmodule PtahServer.DockerSecretsTest do
  use PtahServer.DataCase

  alias PtahServer.DockerSecrets

  describe "docker_secrets" do
    alias PtahServer.DockerSecrets.DockerSecret

    import PtahServer.DockerSecretsFixtures

    @invalid_attrs %{name: nil, ext_id: nil}

    test "list_docker_secrets/0 returns all docker_secrets" do
      docker_secret = docker_secret_fixture()
      assert DockerSecrets.list_docker_secrets() == [docker_secret]
    end

    test "get_docker_secret!/1 returns the docker_secret with given id" do
      docker_secret = docker_secret_fixture()
      assert DockerSecrets.get_docker_secret!(docker_secret.id) == docker_secret
    end

    test "create_docker_secret/1 with valid data creates a docker_secret" do
      valid_attrs = %{name: "some name", ext_id: "some ext_id"}

      assert {:ok, %DockerSecret{} = docker_secret} = DockerSecrets.create_docker_secret(valid_attrs)
      assert docker_secret.name == "some name"
      assert docker_secret.ext_id == "some ext_id"
    end

    test "create_docker_secret/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DockerSecrets.create_docker_secret(@invalid_attrs)
    end

    test "update_docker_secret/2 with valid data updates the docker_secret" do
      docker_secret = docker_secret_fixture()
      update_attrs = %{name: "some updated name", ext_id: "some updated ext_id"}

      assert {:ok, %DockerSecret{} = docker_secret} = DockerSecrets.update_docker_secret(docker_secret, update_attrs)
      assert docker_secret.name == "some updated name"
      assert docker_secret.ext_id == "some updated ext_id"
    end

    test "update_docker_secret/2 with invalid data returns error changeset" do
      docker_secret = docker_secret_fixture()
      assert {:error, %Ecto.Changeset{}} = DockerSecrets.update_docker_secret(docker_secret, @invalid_attrs)
      assert docker_secret == DockerSecrets.get_docker_secret!(docker_secret.id)
    end

    test "delete_docker_secret/1 deletes the docker_secret" do
      docker_secret = docker_secret_fixture()
      assert {:ok, %DockerSecret{}} = DockerSecrets.delete_docker_secret(docker_secret)
      assert_raise Ecto.NoResultsError, fn -> DockerSecrets.get_docker_secret!(docker_secret.id) end
    end

    test "change_docker_secret/1 returns a docker_secret changeset" do
      docker_secret = docker_secret_fixture()
      assert %Ecto.Changeset{} = DockerSecrets.change_docker_secret(docker_secret)
    end
  end
end
