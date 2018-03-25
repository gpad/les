defmodule Les.AccountsTest do
  use Les.DataCase

  alias Les.Accounts

  describe "users" do
    alias Les.Accounts.User
    alias Les.Accounts.Cart

    @valid_attrs %{name: "some name", username: "some username"}
    # @update_attrs %{name: "some updated name", username: "some updated username"}
    # @invalid_attrs %{name: nil, username: nil}

    # defp user_fixture(attrs \\ %{}) do
    #   {:ok, user} =
    #     attrs
    #     |> Enum.into(@valid_attrs)
    #     |> Accounts.create_user()
    #
    #   user
    # end
    #
    test "create empty user with cart and empty items" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert %User{
        cart: %Cart{items: []}
      } = user
    end

    test "reset to a new carts" do
      {:ok, user0} = Accounts.create_user(@valid_attrs)
      {:ok, user1} = Accounts.reset_cart(user0)
      assert user0.cart.id != user1.cart.id
      assert Les.Repo.get!(Cart, user0.cart.id).user_id == nil
    end

    # test "list_users/0 returns all users" do
    #   user = user_fixture()
    #   assert Accounts.list_users() == [user]
    # end
    #
    # test "get_user!/1 returns the user with given id" do
    #   user = user_fixture()
    #   assert Accounts.get_user!(user.id) == user
    # end
    #
    # test "create_user/1 with valid data creates a user" do
    #   assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
    #   assert user.name == "some name"
    #   assert user.username == "some username"
    # end
    #
    # test "create_user/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    # end
    #
    # test "update_user/2 with valid data updates the user" do
    #   user = user_fixture()
    #   assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    #   assert %User{} = user
    #   assert user.name == "some updated name"
    #   assert user.username == "some updated username"
    # end
    #
    # test "update_user/2 with invalid data returns error changeset" do
    #   user = user_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    #   assert user == Accounts.get_user!(user.id)
    # end
    #
    # test "delete_user/1 deletes the user" do
    #   user = user_fixture()
    #   assert {:ok, %User{}} = Accounts.delete_user(user)
    #   assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    # end
    #
    # test "change_user/1 returns a user changeset" do
    #   user = user_fixture()
    #   assert %Ecto.Changeset{} = Accounts.change_user(user)
    # end
  end

  describe "invoices" do
    # alias Les.Accounts.Invoice

    # @valid_attrs %{amount: 10, status: "pending", items: []}
    # @update_attrs %{created_at: ~N[2011-05-18 15:01:01.000000]}
    # @invalid_attrs %{created_at: nil}
    #
    # def invoice_fixture(attrs \\ %{}) do
    #   {:ok, invoice} =
    #     attrs
    #     |> Enum.into(@valid_attrs)
    #     |> Accounts.create_invoice()
    #
    #   invoice
    # end
    #
    # test "list_invoices/0 returns all invoices" do
    #   invoice = invoice_fixture()
    #   assert Accounts.list_invoices() == [invoice]
    # end
    #
    # test "get_invoice!/1 returns the invoice with given id" do
    #   invoice = invoice_fixture()
    #   assert Accounts.get_invoice!(invoice.id) == invoice
    # end
    #
    test "create_invoice/1 with valid data creates a invoice" do
      {:ok, user} = Accounts.create_user(%{name: "n1", username: "un1"})
      assert user.id != nil
      assert user.cart.id != nil
      assert user.cart.user_id == user.id
      {:ok, invoice} = Accounts.create_invoice(user.cart)
      assert invoice.amount == Les.Carts.amount(user.cart)
      assert invoice.cart_id == user.cart.id
      assert invoice.user_id == user.id
      assert invoice.status == "pending"
    end
    #
    # test "create_invoice/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Accounts.create_invoice(@invalid_attrs)
    # end

    test "update_invoice/2 with valid data updates the invoice" do
      {:ok, user} = Accounts.create_user(%{name: "n1", username: "un1"})
      {:ok, invoice} = Accounts.create_invoice(user.cart)
      {:ok, invoice} = Accounts.update_invoice(invoice, %{status: "paid"})
      assert invoice.status == "paid"
    end

    # test "delete_invoice/1 deletes the invoice" do
    #   invoice = invoice_fixture()
    #   assert {:ok, %Invoice{}} = Accounts.delete_invoice(invoice)
    #   assert_raise Ecto.NoResultsError, fn -> Accounts.get_invoice!(invoice.id) end
    # end
    #
    # test "change_invoice/1 returns a invoice changeset" do
    #   invoice = invoice_fixture()
    #   assert %Ecto.Changeset{} = Accounts.change_invoice(invoice)
    # end
  end

  # describe "invoice_items" do
  #   alias Les.Accounts.InvoiceItem
  #
  #   @valid_attrs %{product_id: "7488a646-e31f-11e4-aace-600308960662"}
  #   @update_attrs %{product_id: "7488a646-e31f-11e4-aace-600308960668"}
  #   @invalid_attrs %{product_id: nil}
  #
  #   def invoice_item_fixture(attrs \\ %{}) do
  #     {:ok, invoice_item} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Accounts.create_invoice_item()
  #
  #     invoice_item
  #   end
  #
  #   test "list_invoice_items/0 returns all invoice_items" do
  #     invoice_item = invoice_item_fixture()
  #     assert Accounts.list_invoice_items() == [invoice_item]
  #   end
  #
  #   test "get_invoice_item!/1 returns the invoice_item with given id" do
  #     invoice_item = invoice_item_fixture()
  #     assert Accounts.get_invoice_item!(invoice_item.id) == invoice_item
  #   end
  #
  #   test "create_invoice_item/1 with valid data creates a invoice_item" do
  #     assert {:ok, %InvoiceItem{} = invoice_item} = Accounts.create_invoice_item(@valid_attrs)
  #     assert invoice_item.product_id == "7488a646-e31f-11e4-aace-600308960662"
  #   end
  #
  #   test "create_invoice_item/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Accounts.create_invoice_item(@invalid_attrs)
  #   end
  #
  #   test "update_invoice_item/2 with valid data updates the invoice_item" do
  #     invoice_item = invoice_item_fixture()
  #     assert {:ok, invoice_item} = Accounts.update_invoice_item(invoice_item, @update_attrs)
  #     assert %InvoiceItem{} = invoice_item
  #     assert invoice_item.product_id == "7488a646-e31f-11e4-aace-600308960668"
  #   end
  #
  #   test "update_invoice_item/2 with invalid data returns error changeset" do
  #     invoice_item = invoice_item_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Accounts.update_invoice_item(invoice_item, @invalid_attrs)
  #     assert invoice_item == Accounts.get_invoice_item!(invoice_item.id)
  #   end
  #
  #   test "delete_invoice_item/1 deletes the invoice_item" do
  #     invoice_item = invoice_item_fixture()
  #     assert {:ok, %InvoiceItem{}} = Accounts.delete_invoice_item(invoice_item)
  #     assert_raise Ecto.NoResultsError, fn -> Accounts.get_invoice_item!(invoice_item.id) end
  #   end
  #
  #   test "change_invoice_item/1 returns a invoice_item changeset" do
  #     invoice_item = invoice_item_fixture()
  #     assert %Ecto.Changeset{} = Accounts.change_invoice_item(invoice_item)
  #   end
  # end

  # describe "invoice_payment_log" do
  #   alias Les.Accounts.InvoicePaymentLog
  #
  #   @valid_attrs %{result: 42, result_message: "some result_message"}
  #   @update_attrs %{result: 43, result_message: "some updated result_message"}
  #   @invalid_attrs %{result: nil, result_message: nil}
  #
  #   def invoice_payment_log_fixture(attrs \\ %{}) do
  #     {:ok, invoice_payment_log} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Accounts.create_invoice_payment_log()
  #
  #     invoice_payment_log
  #   end
  #
  #   test "list_invoice_payment_log/0 returns all invoice_payment_log" do
  #     invoice_payment_log = invoice_payment_log_fixture()
  #     assert Accounts.list_invoice_payment_log() == [invoice_payment_log]
  #   end
  #
  #   test "get_invoice_payment_log!/1 returns the invoice_payment_log with given id" do
  #     invoice_payment_log = invoice_payment_log_fixture()
  #     assert Accounts.get_invoice_payment_log!(invoice_payment_log.id) == invoice_payment_log
  #   end
  #
  #   test "create_invoice_payment_log/1 with valid data creates a invoice_payment_log" do
  #     assert {:ok, %InvoicePaymentLog{} = invoice_payment_log} = Accounts.create_invoice_payment_log(@valid_attrs)
  #     assert invoice_payment_log.created_at == ~N[2010-04-17 14:00:00.000000]
  #     assert invoice_payment_log.result == 42
  #     assert invoice_payment_log.result_message == "some result_message"
  #   end
  #
  #   test "create_invoice_payment_log/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Accounts.create_invoice_payment_log(@invalid_attrs)
  #   end
  #
  #   test "update_invoice_payment_log/2 with valid data updates the invoice_payment_log" do
  #     invoice_payment_log = invoice_payment_log_fixture()
  #     assert {:ok, invoice_payment_log} = Accounts.update_invoice_payment_log(invoice_payment_log, @update_attrs)
  #     assert %InvoicePaymentLog{} = invoice_payment_log
  #     assert invoice_payment_log.created_at == ~N[2011-05-18 15:01:01.000000]
  #     assert invoice_payment_log.result == 43
  #     assert invoice_payment_log.result_message == "some updated result_message"
  #   end
  #
  #   test "update_invoice_payment_log/2 with invalid data returns error changeset" do
  #     invoice_payment_log = invoice_payment_log_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Accounts.update_invoice_payment_log(invoice_payment_log, @invalid_attrs)
  #     assert invoice_payment_log == Accounts.get_invoice_payment_log!(invoice_payment_log.id)
  #   end
  #
  #   test "delete_invoice_payment_log/1 deletes the invoice_payment_log" do
  #     invoice_payment_log = invoice_payment_log_fixture()
  #     assert {:ok, %InvoicePaymentLog{}} = Accounts.delete_invoice_payment_log(invoice_payment_log)
  #     assert_raise Ecto.NoResultsError, fn -> Accounts.get_invoice_payment_log!(invoice_payment_log.id) end
  #   end
  #
  #   test "change_invoice_payment_log/1 returns a invoice_payment_log changeset" do
  #     invoice_payment_log = invoice_payment_log_fixture()
  #     assert %Ecto.Changeset{} = Accounts.change_invoice_payment_log(invoice_payment_log)
  #   end
  # end
end
