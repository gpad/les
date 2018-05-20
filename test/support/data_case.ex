defmodule Les.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Les.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Les.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Les.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Les.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @retry_sleep 100

  def eassert(fun, timeout \\ 5_000) do
    do_eassert(fun, trunc(timeout / @retry_sleep))
  end

  defp do_eassert(fun, 0), do: fun.()
  defp do_eassert(fun, times) do
    try do
      fun.()
    rescue
      _ ->
      Process.sleep(@retry_sleep)
      do_eassert(fun, times - 1)
    end
  end

  def product_fixture(opts \\ []) do
    %Les.Products.Product{
      id: UUID.uuid4(),
      description: "test",
      provider: "test",
      ext_id: 1,
      price: 666,
      qty: 123456,
    } |> Map.merge(Map.new(opts))
  end
end
