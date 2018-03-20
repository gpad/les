defmodule Les.Accounts.CartItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.CartItem


  schema "cart_items" do
    field :description, :string
    field :price, :integer
    field :product_id, :string
    field :qty, :integer

    belongs_to :cart, Les.Accounts.Cart

    timestamps()
  end

  @doc false
  def changeset(%CartItem{} = cart_item, attrs) do
    cart_item
    |> cast(attrs, [:product_id, :description, :qty, :price])
    |> validate_required([:product_id, :description, :qty, :price])
  end

end
