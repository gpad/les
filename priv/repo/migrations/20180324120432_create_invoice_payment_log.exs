defmodule Les.Repo.Migrations.CreateInvoicePaymentLog do
  use Ecto.Migration

  def change do
    create table(:invoice_payment_log) do
      add :result, :integer
      add :result_message, :string

      add :invoice_id, references(:invoices, on_delete: :delete_all)

      timestamps()
    end

    create index(:invoice_payment_log, [:invoice_id])
  end
end
