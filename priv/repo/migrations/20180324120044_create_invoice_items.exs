defmodule Les.Repo.Migrations.CreateInvoiceItems do
  use Ecto.Migration

  def change do
    create table(:invoice_items) do
      add :product_id, :string
      add :description, :string
      add :qty, :integer
      add :price, :integer

      add :invoice_id, references(:invoices, on_delete: :delete_all)

      timestamps()
    end

    create index(:invoice_items, [:invoice_id])
  end
end
