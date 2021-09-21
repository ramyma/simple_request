defmodule SimpleRequest.Repo do
  use Ecto.Repo,
    otp_app: :simple_request,
    adapter: Ecto.Adapters.Postgres
end
