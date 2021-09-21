defmodule SimpleRequest.Values.Updater.ServerTest do
  use SimpleRequest.DataCase

  alias SimpleRequest.Values
  alias SimpleRequest.Values.Updater

  describe "start_link/1" do
    test "successful start" do
      assert _pid = start_supervised!({Updater.Server, mode: :manual, name: :test})
    end
  end

  describe "increment/3" do
    test "successive increments" do
      assert pid = start_supervised!({Updater.Server, mode: :manual, name: :test})
      assert %{key: "test", value: 2} = Updater.Server.increment(pid, "test", 2)
      assert %{key: "test", value: 5} = Updater.Server.increment(pid, "test", 3)
    end
  end

  describe "persist/1" do
    test "persistence" do
      assert pid = start_supervised!({Updater.Server, mode: :manual, name: :test})
      assert %{key: "test", value: 2} = Updater.Server.increment(pid, "test", 2)
      assert %{key: "test", value: 5} = Updater.Server.increment(pid, "test", 3)

      assert [] == Values.list_values()

      send(pid, :tick)

      # Could be better to use Mox and expect a mocked version of the Core module
      # to verify that the persist function was called by sending a message and receiving
      # it outside the expect block, without having to deal with Process.sleep/1 which
      # could be flaky and unreliable xxs

      Process.sleep(20)

      assert [%{key: "test", value: 5}] = Values.list_values()
    end
  end
end
