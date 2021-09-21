defmodule SimpleRequest.ValuesTest do
  use SimpleRequest.DataCase

  alias SimpleRequest.Values

  describe "values" do
    alias SimpleRequest.Values.Value

    @valid_attrs %{key: "test", value: 42}
    @update_attrs %{key: "test", value: 43}
    @invalid_attrs %{value: nil}

    def value_fixture(attrs \\ %{}) do
      {:ok, value} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Values.create_value()

      value
    end

    test "list_values/0 returns all values" do
      value = value_fixture()
      assert Values.list_values() == [value]
    end

    test "list_values_by_keys/1 returns all values using passed in keys" do
      value1 = value_fixture(%{key: "test1", value: 1})
      value2 = value_fixture(%{key: "test2", value: 1})
      value3 = value_fixture(%{key: "test3", value: 1})

      assert Values.list_values_by_keys(["test1", "test2"]) == [value1, value2]
      assert Values.list_values_by_keys(["test3"]) == [value3]
      assert Values.list_values_by_keys(["test1", "test3"]) == [value1, value3]
      assert Values.list_values_by_keys(["test1", "test5"]) == [value1]
    end

    test "get_value!/1 returns the value with given key" do
      value = value_fixture()
      assert Values.get_value!(value.key) == value
    end

    test "create_value/1 with valid data creates a value" do
      assert {:ok, %Value{} = value} = Values.create_value(@valid_attrs)
      assert value.value == 42
    end

    test "create_value/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Values.create_value(@invalid_attrs)
    end

    test "create_values/1 with valid data creates a list of values" do
      attrs =
        %{key: "test", value: 42}
        |> Map.put(:updated_at, NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))
        |> Map.put(:inserted_at, NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))

      assert {1, nil} = Values.create_values([attrs])

      assert [%{key: "test", value: 42}] = Values.list_values()
    end

    test "update_value/2 with valid data updates the value" do
      value = value_fixture()

      assert {:ok, %Value{} = value} = Values.update_value(value, @update_attrs)
      assert value.value == 43
    end

    test "update_value/2 with invalid data returns error changeset" do
      value = value_fixture()
      assert {:error, %Ecto.Changeset{}} = Values.update_value(value, @invalid_attrs)
      assert value == Values.get_value!(value.key)
    end

    test "delete_value/1 deletes the value" do
      value = value_fixture()
      assert {:ok, %Value{}} = Values.delete_value(value)
      assert_raise Ecto.NoResultsError, fn -> Values.get_value!(value.key) end
    end

    test "change_value/1 returns a value changeset" do
      value = value_fixture()
      assert %Ecto.Changeset{} = Values.change_value(value)
    end

    # test "upsert_all/1 upserts passed values" do
    #   value1 = value_fixture(%{key: "test1", value: Enum.random(1..10)})
    #   value2 = value_fixture(%{key: "test2", value: Enum.random(1..10)})

    #   values =
    #     2..5
    #     |> Enum.map(
    #       &Map.from_struct(%Value{
    #         key: "test#{&1}",
    #         value: if(&1 == 2, do: value2.value + 5, else: Enum.random(12..20))
    #       })
    #     )

    #   assert {4, nil} = Values.upsert_all(values)

    #   assert [value1, value2] == Values.list_values()
    # end
  end
end
