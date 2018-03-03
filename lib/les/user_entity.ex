defmodule Les.UserEntity do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:user]
  end

  def get_entity_name(user_id), do: :"user_entity_#{user_id}"

  def create(attrs) do
    with {:ok, user} <- Les.Accounts.create_user(attrs),
         {:ok, _} <- Les.EntitiesSupervisor.start_user(user.id) do
      {:ok, user}
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

  def add_product(pid, product_id, qty) do
    GenServer.call(pid, {:add_product, product_id, qty})
  end

  def start_link(id) do
    GenServer.start_link(__MODULE__, [id], name: get_entity_name(id))
  end

  def init([id]) do
    Logger.info("Start process for user: #{id} - pid: #{inspect self()}")
    user = Les.Accounts.get_user!(id)
    {:ok, %State{user: user}}
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

  def handle_call({:add_product, product_id, qty}, _form, state) do
    {:ok, product} = Les.Accounts.Products.get(product_id)
    {:ok, cart} = Les.Accounts.Cart.find_or_create(%{user_id: state.user.id})
    {:ok, cart} = Les.Accounts.Cart.add_product(cart, product, qty)
    {:reply, cart, state}
  end
end
