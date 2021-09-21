defmodule SimpleRequestWeb.ValueView do
  use SimpleRequestWeb, :view
  alias SimpleRequestWeb.ValueView

  def render("show.json", %{value: value}) do
    %{data: render_one(value, ValueView, "value.json")}
  end

  def render("value.json", %{value: value}) do
    %{key: value.key, value: value.value}
  end
end
