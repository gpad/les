defmodule HTTPFake do
  require Logger

  defmodule Response do
    defstruct [:state_code, :body]
  end

  defmodule Error do
    defstruct [:code, :reason]
  end

  def get(_url) do
    {:ok, %HTTPFake.Response{
      state_code: 200,
      body: Poison.encode!(%{
        products: get_random_product()
      })
    }}
  end

  defp get_random_product() do
    (1..10) |> Enum.map(fn _ ->
      id = :rand.uniform(100_000)
      %{
        id: id,
        description: "product #{id}",
        value: :rand.uniform(100),
        qty: :rand.uniform(100),
      }
    end)
  end
end
