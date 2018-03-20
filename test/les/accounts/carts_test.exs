defmodule Les.CartsTest do
  use Les.DataCase

  alias Les.Accounts

  describe "users" do
    # alias Les.Accounts.User
    # alias Les.Accounts.Cart
    alias Les.Accounts.CartItem

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

    def product_fixture() do
      %Les.Product{
        id: UUID.uuid4(),
        description: "test",
        provider: "test",
        ext_id: 1,
        price: 666,
        qty: 123456,
      }
    end

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

    # test "get_user!/1 returns the user with given id" do
    #   user = user_fixture()
    #   assert Accounts.get_user!(user.id) == user
    # end
    #
    # test "create_user/1 with valid data creates a user" do
    #   assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
    #   assert user.name == "some name"
    #   assert user.username == "some username"
    # end
    #
    # test "create_user/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    # end
    #
    # test "update_user/2 with valid data updates the user" do
    #   user = user_fixture()
    #   assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    #   assert %User{} = user
    #   assert user.name == "some updated name"
    #   assert user.username == "some updated username"
    # end
    #
    # test "update_user/2 with invalid data returns error changeset" do
    #   user = user_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    #   assert user == Accounts.get_user!(user.id)
    # end
    #
    # test "delete_user/1 deletes the user" do
    #   user = user_fixture()
    #   assert {:ok, %User{}} = Accounts.delete_user(user)
    #   assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    # end
    #
    # test "change_user/1 returns a user changeset" do
    #   user = user_fixture()
    #   assert %Ecto.Changeset{} = Accounts.change_user(user)
    # end
  end
end
