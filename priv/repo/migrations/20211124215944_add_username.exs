defmodule Ccg.Repo.Migrations.AddUsername do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :name, :string, size: 20
    end
  end
end
