defmodule SimpleRequest.Values.Updater.Core do
  @moduledoc """
  Core updater logic for updater server
  """
  alias SimpleRequest.Values
  alias SimpleRequest.Values.Value

  @doc """
  Updates passed `state` by incrementing the state values entry having the passed `key`
  by the passed `increment_value`
  """
  def increment(%{values: values} = state, key, increment_value) do
    old_value =
      Map.get(
        values,
        key,
        Values.get_value(key) ||
          %Value{key: key, value: 0}
      )

    %{state | values: Map.put(values, key, increment_value(old_value, increment_value))}
  end

  @doc """
  Increments value by passed `increment_value`
  """
  def increment_value(%{value: old_value} = value, increment_value)
      when is_integer(increment_value) do
    %{value | value: old_value + increment_value}
  end

  @doc """
  Persists the values within passed `state` by updating existing values and creating new ones
  in the database
  """
  def persist(%{values: values_map} = _state) do
    key_list =
      values_map
      |> Map.keys()

    values =
      values_map
      |> Map.values()

    existing_values_from_list = Values.list_values_by_keys(key_list)

    {list_to_update, list_to_insert} =
      values
      |> Enum.reduce({[], []}, fn item, {list_to_update, list_to_insert} ->
        case Enum.find(existing_values_from_list, &(&1.key == item.key)) do
          nil ->
            {list_to_update, [Map.from_struct(item) | list_to_insert]}

          found_value ->
            new_value = Map.merge(found_value, item)
            {[{found_value, Map.from_struct(new_value)} | list_to_update], list_to_insert}
        end
      end)

    # For this use case it was simpler to insert and update one item at a time
    # rather than using insert_all and having to deal with conflicts and input
    # massaging

    list_to_insert
    |> Enum.each(&Values.create_value/1)

    list_to_update
    |> Enum.each(&Values.update_value(elem(&1, 0), elem(&1, 1)))

    :ok
  end
end
