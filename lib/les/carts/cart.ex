defmodule Les.Carts.Cart do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Carts.Cart


  schema "carts" do
    belongs_to :user, Les.Accounts.User
    has_many :items, Les.Carts.CartItem, on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Cart{} = cart, attrs) do
    cart
    |> Les.Repo.preload(:items)
    |> change(attrs)
    |> put_assoc(:items, attrs.items)
  end
end
