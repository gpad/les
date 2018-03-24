defmodule Les.PaymentProcessor do
  use GenStateMachine
  alias Les.Fake
  alias Les.Accounts.Invoice
  require Logger

  def start_link(user_id, %Invoice{}=invoice, payment_data) do
    GenStateMachine.start_link(
      __MODULE__,
      [user_id, invoice, payment_data],
      name: :"payment_#{user_id}_#{invoice.id}")
  end

  # Callbacks
  def init([user_id, invoice, payment_data]) do
    Logger.info "init !!!"
    {
      :ok,
      :started,
      %{
        user_id: user_id,
        invoice: invoice,
        payment_data: payment_data,
        ext_id: nil,
        reason: nil
      },
      [{:next_event, :cast, :pay}]
    }
  end

  def handle_event(:cast, :pay, :started, %{payment_data: payment_data, invoice: invoice} = data) do
    case Fake.Psp.pay(invoice.amount, payment_data) do
      {:ok, ext_id} ->
        {:next_state, :payed, %{data | ext_id: ext_id}, {:next_event, :cast, :respond}}
      {:error, reason} ->
        {:next_state, :refused, %{data | reason: reason}, {:next_event, :cast, :respond}}
    end
  end

  def handle_event(:cast, :respond, :payed, %{user_id: user_id, invoice: invoice, ext_id: ext_id}) do
    {:ok, user} = Les.UserEntity.find(user_id)
    Les.UserEntity.payment_ok(user, invoice.id, ext_id)
    :stop
  end

  def handle_event(:cast, :respond, :refused, %{user_id: user_id, invoice: invoice, reason: reason}) do
    {:ok, user} = Les.UserEntity.find(user_id)
    Les.UserEntity.payment_error(user, invoice.id, reason)
    :stop
  end

  def handle_event(etype, econtent, state, data) do
    Logger.warn("Unknown event: type: #{inspect etype} #{inspect econtent} #{inspect state} #{inspect data}")
    :stop
  end


  # # Start the server
  # {:ok, pid} = GenStateMachine.start_link(Switch, {:off, 0})
  #
  # # This is the client
  # GenStateMachine.cast(pid, :flip)
  # #=> :ok
  #
  # GenStateMachine.call(pid, :get_count)
  # #=> 1

end
