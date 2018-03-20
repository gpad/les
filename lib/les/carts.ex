defmodule Les.Carts do
  import Ecto.Query, warn: false
  alias Les.Repo

  alias Les.Accounts.Cart
  alias Les.Accounts.CartItem
  alias Les.Product

  def add_product(%Cart{}=cart, %Product{}=product, qty) do
    items = update_items(cart, product, qty)
    # IO.inspect(">>> GPAD items: #{inspect items}")
    Cart.changeset(cart, %{items: items})
    # |> IO.inspect()
    |> Repo.update()
  end

  defp update_items(cart, product, qty) do
    cart.items
    |> Enum.filter(fn item -> item.product_id == product.id end)
    |> update_qty(cart, product, qty)
  end

  defp update_qty([], cart, product, qty) do
    cart.items ++ [%CartItem{
      description: product.description,
      price: product.price,
      product_id: product.id,
      qty: qty,
      cart_id: cart.id
    }]
  end
  defp update_qty([item], cart, _product, qty) do
    cart.items ++ [%CartItem{item | qty: item.qty + qty}]
  end

end
