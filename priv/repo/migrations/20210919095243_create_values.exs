defmodule SimpleRequest.Repo.Migrations.CreateValues do
  use Ecto.Migration

  def change do
    create table(:values) do
      add :key, :binary, nullable: false
      add :value, :integer, default: 0, nullable: false

      timestamps()
    end
    create unique_index(:values, [:key])
  end

end
