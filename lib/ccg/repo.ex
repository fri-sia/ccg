defmodule Ccg.Repo do
  use Ecto.Repo,
    otp_app: :ccg,
    adapter: Ecto.Adapters.Postgres
end
