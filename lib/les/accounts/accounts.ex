defmodule Les.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Les.Repo

  alias Les.Accounts.User
  alias Les.Carts.Cart
  alias Les.Invoices.Invoice
  alias Les.Carts.CartItem

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: User |> preload(cart: :items) |> Repo.get!(id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{cart: %Les.Carts.Cart{items: []}}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Les.Invoices.Invoice

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  def create_invoice(%Cart{}= cart) do
    %Invoice{}
    |> Invoice.changeset(build_invoice_from(cart))
    |> Repo.insert()
  end

  def reset_cart(%User{}=user) do
    User.changeset(user, %{cart: %{items: []}})
    |> Repo.update()
  end

  defp build_invoice_from(%Cart{}=cart) do
    %{
      amount: Les.Carts.amount(cart),
      cart_id: cart.id,
      user_id: cart.user_id,
      status: "pending",
      items: build_invoice_items_from(cart.items)
    }
  end

  defp build_invoice_items_from(items) do
    Enum.map(items, fn %CartItem{}=item ->
      %{
        description: item.description,
        price: item.price,
        product_id: item.product_id,
        qty: item.qty,
      }
    end)
  end

  #
  # @doc """
  # Updates a invoice.
  #
  # ## Examples
  #
  #     iex> update_invoice(invoice, %{field: new_value})
  #     {:ok, %Invoice{}}
  #
  #     iex> update_invoice(invoice, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  # @doc """
  # Deletes a Invoice.
  #
  # ## Examples
  #
  #     iex> delete_invoice(invoice)
  #     {:ok, %Invoice{}}
  #
  #     iex> delete_invoice(invoice)
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def delete_invoice(%Invoice{} = invoice) do
  #   Repo.delete(invoice)
  # end
  #
  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking invoice changes.
  #
  # ## Examples
  #
  #     iex> change_invoice(invoice)
  #     %Ecto.Changeset{source: %Invoice{}}
  #
  # """
  # def change_invoice(%Invoice{} = invoice) do
  #   Invoice.changeset(invoice, %{})
  # end
  #
  # alias Les.Invoices.InvoiceItem
  #
  # @doc """
  # Returns the list of invoice_items.
  #
  # ## Examples
  #
  #     iex> list_invoice_items()
  #     [%InvoiceItem{}, ...]
  #
  # """
  # def list_invoice_items do
  #   Repo.all(InvoiceItem)
  # end
  #
  # @doc """
  # Gets a single invoice_item.
  #
  # Raises `Ecto.NoResultsError` if the Invoice item does not exist.
  #
  # ## Examples
  #
  #     iex> get_invoice_item!(123)
  #     %InvoiceItem{}
  #
  #     iex> get_invoice_item!(456)
  #     ** (Ecto.NoResultsError)
  #
  # """
  # def get_invoice_item!(id), do: Repo.get!(InvoiceItem, id)
  #
  # @doc """
  # Creates a invoice_item.
  #
  # ## Examples
  #
  #     iex> create_invoice_item(%{field: value})
  #     {:ok, %InvoiceItem{}}
  #
  #     iex> create_invoice_item(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def create_invoice_item(attrs \\ %{}) do
  #   %InvoiceItem{}
  #   |> InvoiceItem.changeset(attrs)
  #   |> Repo.insert()
  # end
  #
  # @doc """
  # Updates a invoice_item.
  #
  # ## Examples
  #
  #     iex> update_invoice_item(invoice_item, %{field: new_value})
  #     {:ok, %InvoiceItem{}}
  #
  #     iex> update_invoice_item(invoice_item, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def update_invoice_item(%InvoiceItem{} = invoice_item, attrs) do
  #   invoice_item
  #   |> InvoiceItem.changeset(attrs)
  #   |> Repo.update()
  # end
  #
  # @doc """
  # Deletes a InvoiceItem.
  #
  # ## Examples
  #
  #     iex> delete_invoice_item(invoice_item)
  #     {:ok, %InvoiceItem{}}
  #
  #     iex> delete_invoice_item(invoice_item)
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def delete_invoice_item(%InvoiceItem{} = invoice_item) do
  #   Repo.delete(invoice_item)
  # end
  #
  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking invoice_item changes.
  #
  # ## Examples
  #
  #     iex> change_invoice_item(invoice_item)
  #     %Ecto.Changeset{source: %InvoiceItem{}}
  #
  # """
  # def change_invoice_item(%InvoiceItem{} = invoice_item) do
  #   InvoiceItem.changeset(invoice_item, %{})
  # end
  #
  # alias Les.Invoices.InvoicePaymentLog
  #
  # @doc """
  # Returns the list of invoice_payment_log.
  #
  # ## Examples
  #
  #     iex> list_invoice_payment_log()
  #     [%InvoicePaymentLog{}, ...]
  #
  # """
  # def list_invoice_payment_log do
  #   Repo.all(InvoicePaymentLog)
  # end
  #
  # @doc """
  # Gets a single invoice_payment_log.
  #
  # Raises `Ecto.NoResultsError` if the Invoice payment log does not exist.
  #
  # ## Examples
  #
  #     iex> get_invoice_payment_log!(123)
  #     %InvoicePaymentLog{}
  #
  #     iex> get_invoice_payment_log!(456)
  #     ** (Ecto.NoResultsError)
  #
  # """
  # def get_invoice_payment_log!(id), do: Repo.get!(InvoicePaymentLog, id)
  #
  # @doc """
  # Creates a invoice_payment_log.
  #
  # ## Examples
  #
  #     iex> create_invoice_payment_log(%{field: value})
  #     {:ok, %InvoicePaymentLog{}}
  #
  #     iex> create_invoice_payment_log(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def create_invoice_payment_log(attrs \\ %{}) do
  #   %InvoicePaymentLog{}
  #   |> InvoicePaymentLog.changeset(attrs)
  #   |> Repo.insert()
  # end
  #
  # @doc """
  # Updates a invoice_payment_log.
  #
  # ## Examples
  #
  #     iex> update_invoice_payment_log(invoice_payment_log, %{field: new_value})
  #     {:ok, %InvoicePaymentLog{}}
  #
  #     iex> update_invoice_payment_log(invoice_payment_log, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def update_invoice_payment_log(%InvoicePaymentLog{} = invoice_payment_log, attrs) do
  #   invoice_payment_log
  #   |> InvoicePaymentLog.changeset(attrs)
  #   |> Repo.update()
  # end
  #
  # @doc """
  # Deletes a InvoicePaymentLog.
  #
  # ## Examples
  #
  #     iex> delete_invoice_payment_log(invoice_payment_log)
  #     {:ok, %InvoicePaymentLog{}}
  #
  #     iex> delete_invoice_payment_log(invoice_payment_log)
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def delete_invoice_payment_log(%InvoicePaymentLog{} = invoice_payment_log) do
  #   Repo.delete(invoice_payment_log)
  # end
  #
  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking invoice_payment_log changes.
  #
  # ## Examples
  #
  #     iex> change_invoice_payment_log(invoice_payment_log)
  #     %Ecto.Changeset{source: %InvoicePaymentLog{}}
  #
  # """
  # def change_invoice_payment_log(%InvoicePaymentLog{} = invoice_payment_log) do
  #   InvoicePaymentLog.changeset(invoice_payment_log, %{})
  # end
end
