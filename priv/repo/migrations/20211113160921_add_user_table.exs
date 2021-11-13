defmodule Ccg.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, size: 80, null: false
      add :password_hash, :string, size: 255, null: false
      add :is_superuser, :boolean, default: false, null: false

      timestamps()
    end

    unique_index(:users, :email)
  end
end
