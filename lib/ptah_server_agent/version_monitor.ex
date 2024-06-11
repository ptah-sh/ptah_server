defmodule PtahServerAgent.VersionMonitor do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    # TODO: get refresh interval from config
    :timer.send_interval(:timer.seconds(120), :refresh)

    {:ok,
     %{
       latest_version: nil,
       client: client()
     }, {:continue, :refresh}}
  end

  def client() do
    middleware = [
      Tesla.Middleware.JSON
    ]

    Tesla.client(
      middleware,
      Tesla.Adapter.Hackney
    )
  end

  @impl true
  def handle_continue(:refresh, state) do
    update_last_version(state)
  end

  @impl true
  def handle_info(:refresh, state) do
    update_last_version(state)
  end

  @impl true
  def handle_call(:get_latest_version, _from, state) do
    {:reply, state.latest_version, state}
  end

  defp update_last_version(state) do
    latest_version = get_latest_version(state.client)

    if latest_version != state.latest_version do
      Logger.info("New version available: #{latest_version}")
    end

    {:noreply, %{state | latest_version: latest_version}}
  end

  defp get_latest_version(client) do
    # TODO: replace Tesla with Finch
    {:ok, latest} =
      Tesla.get(client, "https://api.github.com/repos/ptah-sh/ptah_agent/releases/latest")

    if latest.body == nil or Enum.empty?(latest.body["assets"]) do
      nil
    else
      latest.body["tag_name"]
    end
  end
end
