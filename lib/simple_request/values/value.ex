defmodule SimpleRequest.Values.Value do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:key, :binary, autogenerate: false}
  schema "values" do
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(value, attrs) do
    value
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end
