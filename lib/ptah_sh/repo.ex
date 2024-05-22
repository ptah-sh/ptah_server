defmodule PtahSh.Repo do
  use Ecto.Repo,
    otp_app: :ptah_sh,
    adapter: Ecto.Adapters.Postgres
end
