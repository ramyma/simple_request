defmodule SimpleRequestWeb.ValueControllerTest do
  use SimpleRequestWeb.ConnCase

  @create_attrs %{
    key: "test",
    value: 2
  }

  @invalid_attrs %{key: "test", value: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # describe "index" do
  #   test "lists all values", %{conn: conn} do
  #     conn = get(conn, Routes.value_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  describe "increment value" do
    test "renders value when data is valid", %{conn: conn} do
      conn = post(conn, Routes.value_path(conn, :increment), @create_attrs)
      assert %{"key" => "test", "value" => 2} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.value_path(conn, :increment), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # describe "increment value" do
  #   # setup [:create_value]

  #   test "renders value when data is valid", %{conn: conn, value: %Value{id: id} = value} do
  #     conn = post(conn, Routes.value_path(conn, :increment, value), value: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, value: value} do
  #     conn = post(conn, Routes.value_path(conn, :increment, value), value: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete value" do
  #   setup [:create_value]

  #   test "deletes chosen value", %{conn: conn, value: value} do
  #     conn = delete(conn, Routes.value_path(conn, :delete, value))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.value_path(conn, :show, value))
  #     end
  #   end
  # end
end
