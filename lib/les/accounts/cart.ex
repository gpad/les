defmodule Les.Accounts.Cart do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.Cart


  schema "carts" do
    belongs_to :user, Les.Accounts.User
    has_many :items, Les.Accounts.CartItem, on_replace: :delete, on_delete: :delete_all

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
