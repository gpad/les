defmodule Les.Accounts.InvoiceItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.InvoiceItem


  schema "invoice_items" do
    field :description, :string
    field :price, :integer
    field :product_id, :string
    field :qty, :integer

    belongs_to :invoice, Les.Accounts.Invoice

    timestamps()
  end

  @doc false
  def changeset(%InvoiceItem{} = invoice_item, attrs) do
    invoice_item
    |> cast(attrs, [:product_id, :description, :price, :qty])
    |> validate_required([:product_id, :description, :price, :qty])
  end
end
