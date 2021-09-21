defmodule SimpleRequest.Values.Updater.Server do
  use GenServer
  require Logger

  alias SimpleRequest.Values.Updater.Core

  @default_tick_duration 10_000

  def start_link(init_args) do
    name = Keyword.get(init_args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [init_args], name: name)
  end

  def increment(pid \\ __MODULE__, key, increment_value) do
    GenServer.call(pid, {:increment, key, increment_value})
  end

  @impl true
  def init(args) do
    mode = Keyword.get(args, :mode, :periodic)
    tick_duration = Keyword.get(args, :tick_duration_in_ms, @default_tick_duration)

    if mode == :periodic do
      Process.send_after(self(), :tick, tick_duration)
    end

    {:ok, %{values: %{}, mode: mode}}
  end

  @impl true
  def handle_call({:increment, key, increment_value}, _from, state) do
    new_state = Core.increment(state, key, increment_value)

    {:reply, Map.get(new_state.values, key), new_state}
  end

  @impl true
  def handle_info(:tick, %{mode: mode} = state) do
    Core.persist(state)

    if mode == :periodic do
      Process.send_after(self(), :tick, @default_tick_duration)
    end

    {:noreply, %{state | values: %{}}}
  end
end
