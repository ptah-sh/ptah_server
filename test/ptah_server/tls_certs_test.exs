defmodule PtahServer.TlsCertsTest do
  use PtahServer.DataCase

  alias PtahServer.TlsCerts

  describe "tls_certs" do
    alias PtahServer.TlsCerts.TlsCert

    import PtahServer.TlsCertsFixtures

    @invalid_attrs %{name: nil, cert: nil}

    test "list_tls_certs/0 returns all tls_certs" do
      tls_cert = tls_cert_fixture()
      assert TlsCerts.list_tls_certs() == [tls_cert]
    end

    test "get_tls_cert!/1 returns the tls_cert with given id" do
      tls_cert = tls_cert_fixture()
      assert TlsCerts.get_tls_cert!(tls_cert.id) == tls_cert
    end

    test "create_tls_cert/1 with valid data creates a tls_cert" do
      valid_attrs = %{name: "some name", cert: "some cert"}

      assert {:ok, %TlsCert{} = tls_cert} = TlsCerts.create_tls_cert(valid_attrs)
      assert tls_cert.name == "some name"
      assert tls_cert.cert == "some cert"
    end

    test "create_tls_cert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TlsCerts.create_tls_cert(@invalid_attrs)
    end

    test "update_tls_cert/2 with valid data updates the tls_cert" do
      tls_cert = tls_cert_fixture()
      update_attrs = %{name: "some updated name", cert: "some updated cert"}

      assert {:ok, %TlsCert{} = tls_cert} = TlsCerts.update_tls_cert(tls_cert, update_attrs)
      assert tls_cert.name == "some updated name"
      assert tls_cert.cert == "some updated cert"
    end

    test "update_tls_cert/2 with invalid data returns error changeset" do
      tls_cert = tls_cert_fixture()
      assert {:error, %Ecto.Changeset{}} = TlsCerts.update_tls_cert(tls_cert, @invalid_attrs)
      assert tls_cert == TlsCerts.get_tls_cert!(tls_cert.id)
    end

    test "delete_tls_cert/1 deletes the tls_cert" do
      tls_cert = tls_cert_fixture()
      assert {:ok, %TlsCert{}} = TlsCerts.delete_tls_cert(tls_cert)
      assert_raise Ecto.NoResultsError, fn -> TlsCerts.get_tls_cert!(tls_cert.id) end
    end

    test "change_tls_cert/1 returns a tls_cert changeset" do
      tls_cert = tls_cert_fixture()
      assert %Ecto.Changeset{} = TlsCerts.change_tls_cert(tls_cert)
    end
  end
end
