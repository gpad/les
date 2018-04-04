defmodule Les.PaymentProcessorSupervisor do
  use Supervisor

  def start_payment(user_id, invoice, payment_data) do
    Supervisor.start_child(__MODULE__, [user_id, invoice, payment_data])
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    Supervisor.init([
      worker(Les.PaymentProcessor, [], restart: :temporary)
      ], strategy: :simple_one_for_one)
  end


end
