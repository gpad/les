defmodule Les.EntityVNode do
  require Logger
  alias Les.UserEntityServer
  @behaviour :riak_core_vnode

  def start_vnode(partition) do
    :riak_core_vnode_master.get_vnode_pid(partition, __MODULE__)
  end

  def init([partition]) do
    Logger.debug("Init on partition: #{inspect partition} - self: #{inspect self()}")
    {:ok, %{partition: partition, data: %{}, me: self(), handoff_running: false}}
  end

  def handle_command({:ping, v}, _sender, state) do
    Logger.debug("[ping received]: with value: #{inspect v} state: #{inspect state.partition} pid: #{inspect self()}... ")
    {:reply, :pong, state}
  end

  def handle_command({:find, user_id}, _sender, state) do
    res = UserEntityServer.find(user_id)
    {:reply, res, state}
  end

  def handle_command({:start_user, user_id, opts}, _sender, state) do
    res = UserEntityServer.start_user(user_id, opts)
    {:reply, res, state}
  end

  def handle_command({:update, user_id, attrs}, _sender, state) do
    {:ok, pid} = UserEntityServer.find(user_id)
    {:ok, new_user} = UserEntityServer.update(pid, attrs)
    {:reply, {:ok, new_user}, state}
  end

  def handle_command({:add_to_cart, user_id, product_id, qty}, _sender, state) do
    {:ok, pid} = UserEntityServer.find(user_id)
    {:ok, new_cart} = UserEntityServer.add_to_cart(pid, product_id, qty)
    {:reply, {:ok, new_cart}, state}
  end

  def handle_command({:checkout_and_pay, user_id}, _sender, state) do
    {:ok, pid} = UserEntityServer.find(user_id)
    {:ok, new_cart} = UserEntityServer.checkout_and_pay(pid)
    {:reply, {:ok, new_cart}, state}
  end

  def handle_command({:invoices, user_id, filter}, _sender, state) do
    {:ok, pid} = UserEntityServer.find(user_id)
    {:ok, invoices} = UserEntityServer.invoices(pid, filter)
    {:reply, {:ok, invoices}, state}
  end

  def handle_command({:payment_error, user_id, invoice_id, reason}, _sender, state) do
    {:ok, pid} = UserEntityServer.find(user_id)
    :ok = UserEntityServer.payment_error(pid, invoice_id, reason)
    {:noreply, state}
  end

  def handle_command({:payment_ok, user_id, invoice_id, exit_id}, _sender, state) do
    {:ok, pid} = UserEntityServer.find(user_id)
    :ok = UserEntityServer.payment_ok(pid, invoice_id, exit_id)
    {:noreply, state}
  end

  def handoff_starting(dest, state) do
    Logger.debug "[handoff_starting] -\n\tdest: #{inspect dest}\n\tstate: #{inspect state}"
    {true, %{state | handoff_running: true}}
  end

  def handoff_cancelled(state) do
    Logger.debug "[handoff_cancelled] state: #{inspect state}"
    {:ok, %{state | handoff_running: false}}
  end

  def handoff_finished(_dest, state) do
    Logger.debug "[handoff_finished] state: #{inspect state}"
    {:ok, %{state | handoff_running: false}}
  end

  require Record
  Record.defrecord :fold_req_v1, :riak_core_fold_req_v1, Record.extract(:riak_core_fold_req_v1, from_lib: "riak_core/include/riak_core_vnode.hrl")
  Record.defrecord :fold_req_v2, :riak_core_fold_req_v2, Record.extract(:riak_core_fold_req_v2, from_lib: "riak_core/include/riak_core_vnode.hrl")

  def handle_handoff_command(fold_req_v1() = fold_req, sender, state) do
    Logger.debug ">>>>> Handoff V1 <<<<<<"
    foldfun = fold_req_v1(fold_req, :foldfun)
    acc0 = fold_req_v1(fold_req, :acc0)
    handle_handoff_command(fold_req_v2(foldfun: foldfun, acc0: acc0), sender, state)
  end

  def handle_handoff_command(fold_req_v2() = fold_req, _sender, state) do
    Logger.debug ">>>>> Handoff V2 me? #{state.me == self()} - self: #{inspect self()} - #{inspect state} <<<<<<"
    true = state.handoff_running
    foldfun = fold_req_v2(fold_req, :foldfun)
    acc0 = fold_req_v2(fold_req, :acc0)
    acc_final = state.data |> Enum.reduce(acc0, fn {k, v}, acc ->
      # Process.sleep(1000)
      foldfun.(k, v, acc)
    end)
    Logger.debug ">>>>> --- <<<<<<"
    {:reply, acc_final, state}
  end

  def handle_handoff_command(request, sender, state) do
    Logger.warn "VVV Handoff generic request me? #{state.me == self()} VVV\n\trequest: #{inspect request}\n\tsender: #{inspect sender}\n\tstate: #{inspect state}"
    {:reply, result, new_state} = handle_command(request, sender, %{state | handoff_running: false})
    Logger.warn "^^^ Handoff generic request  END ^^^"
    {:reply, result, %{new_state | handoff_running: true}}
  end

  def is_empty(state) do
    empty = length(Map.keys(state.data)) == 0
    Logger.debug "[is_empty] ? #{inspect empty} - state: #{inspect state}"
    {empty, state}
  end

  def terminate(reason, state) do
    Logger.debug("[terminate] reason: #{inspect reason} state: #{inspect state}")
    :ok
  end

  def delete(state) do
    Logger.debug "[delete] - #{inspect state}"
    {:ok, Map.put(state, :data, %{})}
  end

  def handle_handoff_data(bin_data, state) do
    # Logger.debug("[handle_handoff_data] bin_data: #{inspect bin_data} - #{inspect state} me? #{state.me == self()}")
    {k, v} = :erlang.binary_to_term(bin_data)
    new_state = Map.update(state, :data, %{}, fn data -> Map.put(data, k, v) end)
    {:reply, :ok, new_state}
  end

  def encode_handoff_item(k, v) do
    # Logger.debug("[encode_handoff_item] #{inspect k} - #{inspect v} - self: #{inspect self()}")
    :erlang.term_to_binary({k, v})
  end

  def handle_coverage({:keys, _, _} = req, _key_spaces, {_, ref_id, _} = sender, state) do
    Logger.debug "[handle_coverage] VNODE req: #{inspect req} sender: #{inspect sender}"
    {:reply, {ref_id, Map.keys(state.data)}, state}
  end

  def handle_coverage({:values, _, _} = req, _key_spaces, {_, ref_id, _} = sender, state) do
    Logger.debug "[handle_coverage] VNODE req: #{inspect req} sender: #{inspect sender}"
    {:reply, {ref_id, Map.values(state.data)}, state}
  end

  def handle_exit(pid, reason, state) do
    Logger.debug "[handle_exit] self: #{inspect self()} - pid: #{inspect pid} - reason: #{inspect reason} - state: #{inspect state}"
    {:noreply, state}
  end

  def handle_overload_command(_, _, _), do: :ok
  def handle_overload_info(_, _), do: :ok

end
