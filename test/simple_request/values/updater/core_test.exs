defmodule SimpleRequest.Values.Updater.CoreTest do
  use SimpleRequest.DataCase

  alias SimpleRequest.Values.Updater.Core
  alias SimpleRequest.Values
  alias SimpleRequest.Values.Value

  describe "test increment/3" do
    test "" do
      state = Core.increment(%{values: %{}}, "test", 1)
      assert %{values: %{"test" => %Value{key: "test", value: 1}}} = state

      state = Core.increment(state, "test", 20)
      assert %{values: %{"test" => %Value{key: "test", value: 21}}} = state

      state = Core.increment(state, "test", -1)
      assert %{values: %{"test" => %Value{key: "test", value: 20}}} = state

      state = Core.increment(state, "test2", 1)

      assert %{
               values: %{
                 "test2" => %Value{key: "test2", value: 1},
                 "test" => %Value{key: "test", value: 20}
               }
             } = state
    end
  end

  describe "test increment_value/2" do
    test "" do
      assert %{key: "test", value: 1} = Core.increment_value(%Value{key: "test", value: 0}, 1)

      assert %{key: "test", value: 21} = Core.increment_value(%Value{key: "test", value: 10}, 11)

      assert %{key: "test", value: 0} = Core.increment_value(%Value{key: "test", value: 1}, -1)
    end
  end

  describe "test persist/1" do
    test "" do
      {:ok, value1} = Values.create_value(%{key: "test1", value: Enum.random(1..10)})
      {:ok, value2} = Values.create_value(%{key: "test2", value: Enum.random(1..10)})

      values_to_persist =
        2..5
        |> Enum.reduce(%{}, fn num, acc ->
          Map.put(acc, "test#{num}", %Value{
            key: "test#{num}",
            value: if(num == 2, do: value2.value + 1, else: Enum.random(1..10))
          })
        end)

      assert :ok = Core.persist(%{values: values_to_persist})

      assert Enum.sort([value1, %{value2 | value: value2.value + 1}], &(&1.key >= &2.key))
      Enum.sort(Values.list_values(), &(&1.key >= &2.key))
    end
  end
end
