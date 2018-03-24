defmodule Les.Accounts.InvoicePaymentLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.InvoicePaymentLog


  schema "invoice_payment_log" do
    field :result, :integer
    field :result_message, :string

    belongs_to :invoice, Les.Accounts.Invoice
    timestamps()
  end

  @doc false
  def changeset(%InvoicePaymentLog{} = invoice_payment_log, attrs) do
    invoice_payment_log
    |> cast(attrs, [:result, :result_message])
    |> validate_required([:result, :result_message])
  end
end
