defmodule Les.UserEntityTest do
  use Les.DataCase
  alias Les.UserEntity

  test "create a new entity" do
    {:ok, user, pid} = UserEntity.create(%{name: "n1", username: "un1"})
    assert %Les.Accounts.User{} = user
    assert is_pid(pid)
  end

  test "add product to user" do
    product = Les.CartsTest.product_fixture()
    defmodule FakeProducts do
      def get(_) do
        {:ok, Les.CartsTest.product_fixture()}
      end
    end
    {:ok, _, pid} = UserEntity.create(%{name: "n1", username: "un1"}, [products: FakeProducts])

    UserEntity.add_to_cart(pid, product.id, 1)
  end
end
