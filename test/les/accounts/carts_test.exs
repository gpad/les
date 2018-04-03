defmodule Les.CartsTest do
  use Les.DataCase

  alias Les.Accounts

  describe "users" do
    # alias Les.Accounts.User
    # alias Les.Carts.Cart
    alias Les.Carts.CartItem

    @valid_attrs %{name: "some name", username: "some username"}
    # @update_attrs %{name: "some updated name", username: "some updated username"}
    # @invalid_attrs %{name: nil, username: nil}

    # defp user_fixture(attrs \\ %{}) do
    #   {:ok, user} =
    #     attrs
    #     |> Enum.into(@valid_attrs)
    #     |> Accounts.create_user()
    #
    #   user
    # end

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

    # test "add same item two times" do
    #   {:ok, user} = Accounts.create_user(@valid_attrs)
    #   product = product_fixture()
    #   {:ok, cart} = Les.Carts.add_product(user.cart, product, 1)
    #   {:ok, cart} = Les.Carts.add_product(cart, product, 1)
    #   assert [%CartItem{}=item] = cart.items
    #   assert item.cart_id == cart.id
    #   assert item.description == product.description
    #   assert item.price == product.price
    #   assert item.product_id == product.id
    #   assert item.qty == 2
    # end

  end
end
