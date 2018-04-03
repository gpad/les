defmodule Les.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.User


  schema "users" do
    field :name, :string
    field :username, :string
    has_one :cart, Les.Carts.Cart, on_delete: :delete_all, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> Les.Repo.preload(cart: :items)
    |> cast(attrs, [:name, :username])
    |> cast_assoc(:cart)
    |> unique_constraint(:username)
    |> validate_required([:name, :username])
  end
end
