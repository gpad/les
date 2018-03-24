defmodule Les.Accounts.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Les.Accounts.Invoice


  schema "invoices" do
    field :amount, :integer
    field :status, :string

    belongs_to :user, Les.Accounts.User
    belongs_to :cart, Les.Accounts.Cart
    has_many :items, Les.Accounts.InvoiceItem, on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    invoice
    |> cast(attrs, [:amount, :status, :cart_id, :user_id])
    |> validate_required([:amount, :status, :cart_id, :user_id])
  end
end
