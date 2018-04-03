defmodule Les.UserEntityTest do
  use Les.DataCase
  alias Les.UserEntity
  alias Les.Product
  alias Les.Carts.CartItem

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
    [%Les.Carts.CartItem{}=item] = cart.items
    assert_item(item, product, 1)
  end

  test "add more different products on cart get one lines for product" do
    p1 = Les.CartsTest.product_fixture()
    p2 = Les.CartsTest.product_fixture(description: "t2", ext_id: 2)
    FakeProducts.add(p1)
    FakeProducts.add(p2)
    {:ok, _, pid} = UserEntity.create(%{name: "n1", username: "un1"}, [products: FakeProducts])
    {:ok, _} = UserEntity.add_to_cart(pid, p1.id, 1)
    {:ok, cart} = UserEntity.add_to_cart(pid, p2.id, 1)
    assert [%CartItem{}=i1, %CartItem{}=i2] = cart.items
    assert_item(i1, p1, 1)
    assert_item(i2, p2, 1)
  end

  # test "add more same product on cart increment qty" do
  #   product = Les.CartsTest.product_fixture()
  #   FakeProducts.add(product)
  #   {:ok, _, pid} = UserEntity.create(%{name: "n1", username: "un1"}, [products: FakeProducts])
  #   {:ok, _} = UserEntity.add_to_cart(pid, product.id, 1)
  #   {:ok, cart} = UserEntity.add_to_cart(pid, product.id, 1)
  #   [%Les.Carts.CartItem{}=item] = cart.items
  #   assert_item(item, product, 2)
  # end

  # test "add product return false if not enough qty available"

  @tag timeout: 15_000
  test "checkout and pay could receive payment error" do
    product = Les.CartsTest.product_fixture()
    FakeProducts.add(product)
    {:ok, user, pid} = UserEntity.create(%{name: "n1", username: "un1"}, [products: FakeProducts])
    {:ok, cart} = UserEntity.add_to_cart(pid, product.id, 1)
    {:ok, invoice_id} = UserEntity.checkout_and_pay(pid)
    eassert(fn ->
      assert {:ok, [invoice]} = UserEntity.invoices(pid, id: invoice_id)
      assert invoice.cart_id == cart.id
      assert invoice.user_id == user.id
      assert invoice.id == invoice_id
      assert invoice.status in ["paid", "payment_error"]
      assert invoice.amount == Les.Carts.amount(cart)
    end, 10_000)
  end

  def assert_item(%CartItem{}=item, %Product{}=product, qty) do
      assert item.product_id == product.id
      assert item.description == product.description
      assert item.price == product.price
      assert item.product_id == product.id
      assert item.qty == qty
  end
end
