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
end
