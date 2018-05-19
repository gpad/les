defmodule Les.CartsTest do
  use Les.DataCase

  alias Les.Accounts

  describe "carts" do
    alias Les.Carts.CartItem

    @valid_attrs %{name: "some name", username: "some username"}

    test "add item in a empty cart" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      product = product_fixture()
      {:ok, cart} = Les.Carts.add_product(user.cart, product, 1)
      assert [%CartItem{}=item] = cart.items
      assert item.cart_id == cart.id
      assert item.description == product.description
      assert item.price == product.price
      assert item.product_id == product.id
      assert item.qty == 1
    end

    test "add same item two times" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      product = product_fixture()
      {:ok, cart} = Les.Carts.add_product(user.cart, product, 1)
      {:ok, cart} = Les.Carts.add_product(cart, product, 1)
      assert length(cart.items) == 1
      assert [%CartItem{}=item] = cart.items
      assert item.cart_id == cart.id
      assert item.description == product.description
      assert item.price == product.price
      assert item.product_id == product.id
      assert item.qty == 2
    end
  end
end
