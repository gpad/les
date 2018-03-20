defmodule Les.UserEntity do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:user, :cart, :products]
  end

  def get_entity_name(user_id), do: :"user_entity_#{user_id}"

  def create(attrs, opts \\ [products: Les.Products]) do
    with {:ok, user} <- Les.Accounts.create_user(attrs),
         {:ok, pid} <- Les.EntitiesSupervisor.start_user(user.id, opts) do
      {:ok, user, pid}
    else
      error -> error
    end
  end

  def find(user_id) do
    case Les.EntitiesSupervisor.find_user(user_id) do
      {:ok, pid} -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end

  def update(pid, attrs) do
    GenServer.call(pid, {:update, attrs})
  end

  def get(pid) do
    GenServer.call(pid, {:get})
  end

  def add_to_cart(pid, product_id, qty) do
    GenServer.call(pid, {:add_to_cart, product_id, qty})
  end

  def start_link(id, opts \\ []) do
    GenServer.start_link(__MODULE__, [id, opts], name: get_entity_name(id))
  end

  def init([id, opts]) do
    Logger.info("Start process for user: #{id} - pid: #{inspect self()}")
    user = Les.Accounts.get_user!(id)
    {:ok, %State{user: user, cart: user.cart, products: Keyword.get(opts, :products)}}
  end

  def handle_call({:update, attrs}, _form, state) do
    {res, new_state} =
      case Les.Accounts.update_user(state.user, attrs) do
        {:ok, user} -> {{:ok, user}, %{state | user: user}}
        res -> {res, state}
      end
    {:reply, res, new_state}
  end

  def handle_call({:get}, _form, state) do
    {:reply, state.user, state}
  end

  def handle_call({:add_to_cart, product_id, qty}, _form, %{cart: cart, products: products}=state) do
    {:ok, product} = products.get(product_id)
    {:ok, new_cart} = Les.Carts.add_product(cart, product, qty)
    {:reply, new_cart, %{state| cart: new_cart}}
  end
end
