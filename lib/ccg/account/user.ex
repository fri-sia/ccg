defmodule Ccg.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ccg.Account.User

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :is_superuser, :boolean

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash, :is_superuser])
    |> validate_required([:email, :password_hash])
  end


end
