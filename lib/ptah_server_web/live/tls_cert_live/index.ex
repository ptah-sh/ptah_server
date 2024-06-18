defmodule PtahServerWeb.TlsCertLive.Index do
  use PtahServerWeb, :live_view

  alias PtahServer.TlsCerts
  alias PtahServer.TlsCerts.TlsCert

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tls_certs, TlsCerts.list_tls_certs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tls cert")
    |> assign(:tls_cert, TlsCerts.get_tls_cert!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tls cert")
    |> assign(:tls_cert, %TlsCert{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tls certs")
    |> assign(:tls_cert, nil)
  end

  @impl true
  def handle_info({PtahServerWeb.TlsCertLive.FormComponent, {:saved, tls_cert}}, socket) do
    {:noreply, stream_insert(socket, :tls_certs, tls_cert)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tls_cert = TlsCerts.get_tls_cert!(id)
    {:ok, _} = TlsCerts.delete_tls_cert(tls_cert)

    {:noreply, stream_delete(socket, :tls_certs, tls_cert)}
  end
end
