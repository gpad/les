defmodule Les.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.User


  schema "users" do
    field :name, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_required([:name, :username])
    |> unique_constraint(:username)
  end
end
