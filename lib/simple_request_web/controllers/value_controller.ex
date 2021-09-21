defmodule SimpleRequestWeb.ValueController do
  use SimpleRequestWeb, :controller

  action_fallback SimpleRequestWeb.FallbackController

  def increment(conn, %{"key" => key, "value" => value})
      when is_binary(key) and is_number(value) do
    render(conn, "show.json", value: SimpleRequest.Values.increment_value(key, value))
  end

  def increment(conn, _params) do
    conn =
      conn
      |> put_status(422)

    json(conn, %{error: %{message: "Make sure a string 'key' and an integer 'value' are passed."}})
  end
end
