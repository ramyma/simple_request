defmodule SimpleRequest.Values.Updater.Supervisor do
  use Supervisor
  alias SimpleRequest.Values.Updater

  def start_link(args) do
    Supervisor.start_link(__MODULE__, [args], name: __MODULE__)
  end

  def init([_args]) do
    children = [
      Updater.Server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
