defmodule Les.Carts do
  import Ecto.Query, warn: false
  alias Les.Repo

  alias Les.Carts.Cart
  alias Les.Carts.CartItem
  alias Les.Product

  def amount(%Cart{}=cart) do
    Enum.reduce(cart.items, 0, &(&1.price + &2))
  end

  def add_product(%Cart{}=cart, %Product{}=product, qty) do
    items = update_items(cart, product, qty)
    Cart.changeset(cart, %{items: items})
    |> Repo.update()
  end

  defp update_items(cart, product, qty) do
    cart.items
    |> Enum.split_with(&(&1.product_id == product.id))
    |> update_qty(cart.id, product, qty)
  end

  # add always a new line ...
  defp update_qty({o1, others}, cart_id, product, qty) do
    others ++ o1 ++ [%CartItem{
      description: product.description,
      price: product.price,
      product_id: product.id,
      qty: qty,
      cart_id: cart_id
    }]
  end
  # defp update_qty({[], others}, cart_id, product, qty) do
  #   others ++ [%CartItem{
  #     description: product.description,
  #     price: product.price,
  #     product_id: product.id,
  #     qty: qty,
  #     cart_id: cart_id
  #   }]
  # end
  # defp update_qty({[item], others}, _cart_id, _product, qty) do
  #   others ++ [%CartItem{item | qty: item.qty + qty}]
  # end
end
