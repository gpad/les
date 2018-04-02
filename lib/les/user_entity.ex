defmodule Les.UserEntity do
  require Logger

  # TODO create user on vnode? If I don't have the user_id
  # how can I find it? (UUID?!?)
  def create(attrs, opts \\ [products: Les.Products]) do
    with {:ok, user} <- Les.Accounts.create_user(attrs),
         {:ok, pid} <- execute_command(user.id, :start_user, [opts]) do
      {:ok, user, pid}
    else
      error -> error
    end
  end

  def find(user_id) do
    execute_command(user_id, :find)
  end

  def update(user_id, attrs) do
    execute_command(user_id, :update, [attrs])
  end

  def get(user_id) do
    execute_command(user_id, :get)
  end

  def add_to_cart(user_id, product_id, qty) do
    execute_command(user_id, :add_to_cart, [product_id, qty])
  end

  def checkout_and_pay(user_id) do
    execute_command(user_id, :checkout_and_pay)
  end

  def invoices(user_id, filter) do
    execute_command(user_id, :invoices, [filter])
  end

  def payment_error(user_id, invoice_id, reason) do
    execute_command(user_id, :payment_error, [invoice_id, reason])
  end

  def payment_ok(user_id, invoice_id, ext_id) do
    execute_command(user_id, :payment_ok, [invoice_id, ext_id])
  end

  defp execute_command(user_id, command, args \\ []) do
    idx = :riak_core_util.chash_key({"user", user_id})
    # pref_list = :riak_core_apl.get_primary_apl(idx, 1, Les.EntityService)
    # [{index_node, :primary}] = pref_list
    pref_list = :riak_core_apl.get_apl(idx, 1, Les.EntityService)
    [index_node] = pref_list
    message = ([command, user_id] ++ args) |> List.to_tuple
    :riak_core_vnode_master.sync_command(index_node, message, Les.EntityVNode_master)
  end
end
