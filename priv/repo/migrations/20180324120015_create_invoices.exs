defmodule Les.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :cart_id, references(:carts, on_delete: :nothing)
      add :amount, :integer
      add :status, :string

      timestamps()
    end

    create index(:invoices, [:user_id])
  end
end
