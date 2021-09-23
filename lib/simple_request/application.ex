defmodule SimpleRequest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SimpleRequest.PromEx,
      # Start the Ecto repository
      SimpleRequest.Repo,
      # Start the Telemetry supervisor
      SimpleRequestWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SimpleRequest.PubSub},
      # Start the Endpoint (http/https)
      SimpleRequestWeb.Endpoint,
      # Start a worker by calling: SimpleRequest.Worker.start_link(arg)
      # {SimpleRequest.Worker, arg}
      SimpleRequest.Values.Updater.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleRequest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SimpleRequestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
