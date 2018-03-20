defmodule Les.Repo.Migrations.CreateCartItems do
  use Ecto.Migration

  def change do
    create table(:cart_items) do
      add :product_id, :string
      add :description, :string
      add :qty, :integer
      add :price, :integer

      add :cart_id, references(:carts, on_delete: :delete_all)

      timestamps()
    end

    create index(:cart_items, [:cart_id])
  end
end
