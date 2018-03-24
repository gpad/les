defmodule Les.Fake.Psp do
  require Logger

  def pay(amount, _payment_data) do
    sleep_for = 2_000 + :rand.uniform(3_000)
    Logger.info(">>> Require payment of #{amount}$ will take #{sleep_for/1000} seconds.")
    Process.sleep(sleep_for)
    create_payment_result(:rand.uniform() > 0.5)
  end

  defp create_payment_result(true) do
    {:ok, UUID.uuid4()}
  end

  defp create_payment_result(false) do
    {:error, Enum.random([
      "insufficient funds",
      "card is invalid",
      "today is a bad day",
      ])
    }
  end

  # defmodule Response do
  #   defstruct [:state_code, :body]
  # end
  #
  # defmodule Error do
  #   defstruct [:code, :reason]
  # end
  #
  # def get(_url) do
  #   {:ok, %HTTPFake.Response{
  #     state_code: 200,
  #     body: Poison.encode!(%{
  #       products: get_random_product()
  #     })
  #   }}
  # end
  #
  # defp get_random_product() do
  #   (1..10) |> Enum.map(fn _ ->
  #     id = :rand.uniform(100_000)
  #     %{
  #       id: id,
  #       description: "product #{id}",
  #       value: :rand.uniform(100),
  #       qty: :rand.uniform(100),
  #     }
  #   end)
  # end
end
