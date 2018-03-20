defmodule Les.UserEntityTest do
  use Les.DataCase
  alias Les.UserEntity

  defmodule FakeProducts do
    def start_link() do
      Agent.start_link(fn -> %{} end, name: __MODULE__)
    end

    def add(%Les.Product{id: id} = product) do
      Agent.update(__MODULE__, fn state -> Map.put(state, id, product) end)
    end
    def get(id) do
      product = Agent.get(__MODULE__, fn state -> Map.get(state, id) end)
      {:ok, product}
    end
  end

  setup _ do
    FakeProducts.start_link()
    :ok
  end

  test "create a new entity" do
    {:ok, user, pid} = UserEntity.create(%{name: "n1", username: "un1"})
    assert %Les.Accounts.User{} = user
    assert is_pid(pid)
  end

  test "add product to user" do
    product = Les.CartsTest.product_fixture()
    FakeProducts.add(product)
    {:ok, _, pid} = UserEntity.create(%{name: "n1", username: "un1"}, [products: FakeProducts])
    {:ok, cart} = UserEntity.add_to_cart(pid, product.id, 1)
    [%Les.Accounts.CartItem{}=item] = cart.items
    assert item.product_id == product.id
    assert item.description == product.description
    assert item.price == product.price
    assert item.product_id == product.id
    assert item.qty == 1
  end

  test "add more different products on cart get one lines for product"
  test "add more same product on cart increment qty"

  test "add product return false if not enough qty available"

  test "check and pay contatct wharehous to verify qty"
end
