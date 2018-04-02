defmodule Les.UserEntityServer do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:user, :cart, :products, :invoices, :running_payments]
  end

  def get_entity_name(user_id), do: :"user_entity_#{user_id}"

  # def create(attrs, opts \\ [products: Les.Products]) do
  #   with {:ok, user} <- Les.Accounts.create_user(attrs),
  #        {:ok, pid} <- Les.EntitiesSupervisor.start_user(user.id, opts) do
  #     {:ok, user, pid}
  #   else
  #     error -> error
  #   end
  # end

  def start_user(user_id, opts) do
    res = Les.EntitiesSupervisor.start_local_user(user_id, opts)
    case res do
      {:ok, pid} -> {:ok, pid}
      _ -> res
    end
  end

  def find(user_id) do
    case Les.EntitiesSupervisor.find_local_user(user_id) do
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

  def checkout_and_pay(pid) do
    GenServer.call(pid, :checkout_and_pay)
  end

  def invoices(pid, filter) do
    GenServer.call(pid, {:invoices, filter})
  end

  def payment_error(pid, invoice_id, reason) do
    GenServer.cast(pid, {:payment_error, invoice_id, reason})
  end

  def payment_ok(pid, invoice_id, ext_id) do
    GenServer.cast(pid, {:payment_ok, invoice_id, ext_id})
  end

  def start_link(id, opts \\ []) do
    GenServer.start_link(__MODULE__, [id, opts], name: get_entity_name(id))
  end

  def init([id, opts]) do
    Logger.info("Start process for user: #{id} - pid: #{inspect self()}")
    user = Les.Accounts.get_user!(id)
    {:ok, %State{
      user: user,
      cart: user.cart,
      products: Keyword.get(opts, :products),
      invoices: %{}, # TODO load pending invoices from DB
      running_payments: %{} # Can I get this value from supervisor ?!?
    }}
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
    {:reply, {:ok, state.user}, state}
  end

  def handle_call({:add_to_cart, product_id, qty}, _form, %{cart: cart, products: products}=state) do
    {:ok, product} = products.get(product_id)
    {:ok, new_cart} = Les.Carts.add_product(cart, product, qty)
    {:reply, {:ok, new_cart}, %{state| cart: new_cart}}
  end

  def handle_call(:checkout_and_pay, _from, %{cart: cart, user: user, invoices: invoices, running_payments: running_payments} = state) do
    # TODO - BEGIN TRN
    {:ok, invoice} = Les.Accounts.create_invoice(cart)
    {:ok, user} = Les.Accounts.reset_cart(user)
    {:ok, payment_pid} = Les.PaymentProcessorSupervisor.start_payment(user.id, invoice, %{car_number: "1234"})
    # TODO - END TRN

    # How to manage a possibile fail ?!?
    # 1 - set a timout here
    # 2 - monitor il payment processor
    # 3 - spawn a watcher that can ?!?

    new_state = %{state |
      invoices: add_invoice(invoices, invoice),
      cart: user.cart,
      user: user,
      running_payments: add_running_payments(running_payments, payment_pid, invoice.id)
    }
    {:reply, {:ok, invoice.id}, new_state}
  end

  def handle_call({:invoices, filter}, _from, %{invoices: invoices}=state) do
    ret = Enum.filter(invoices, fn {_, invoice} ->
      Enum.all?(filter, fn {k, v} ->
        Map.get(invoice, k) == v
      end)
    end) |> Enum.map(fn {_, invoice} -> invoice end)
    {:reply, {:ok, ret}, state}
  end

  def handle_cast({:payment_error, invoice_id, _reason}, %{invoices: invoices}=state) do
    {:ok, invoice} = Les.Accounts.update_invoice(get_invoice(invoices, invoice_id), %{status: "payment_error"})
    new_state = %{state | invoices: add_invoice(invoices, invoice)}
    {:noreply, new_state}
  end

  def handle_cast({:payment_ok, invoice_id, _ext_id}, %{invoices: invoices}=state) do
    {:ok, invoice} = Les.Accounts.update_invoice(get_invoice(invoices, invoice_id), %{status: "paid"})
    new_state = %{state | invoices: add_invoice(invoices, invoice)}
    {:noreply, new_state}
  end

  defp add_invoice(invoices, invoice) do
    Map.put(invoices, invoice.id, invoice)
  end

  defp get_invoice(invoices, id) do
    Map.get(invoices, id)
  end

  defp add_running_payments(%{}=running_payments, pid, invoice_id) do
    Map.put(running_payments, pid, invoice_id)
  end
end
