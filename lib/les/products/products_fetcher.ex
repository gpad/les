defmodule Les.Products.Fetcher do
  use GenServer
  require Logger

  @interval_ms 60_000

  def start_link(provider) do
    GenServer.start_link(__MODULE__, [provider], [])
  end

  def init([provider]) do
    # Logger.info("Start a new fetcher for #{provider}")
    send(self(), :fetch)
    {:ok, provider}
  end

  def handle_info(:fetch, provider) do
    products = fetch_provider(provider)
    send(Process.whereis(Les.Products), {:products, provider, products})
    Process.send_after(self(), :fetch, @interval_ms)
    {:noreply, provider}
  end

  defp fetch_provider(provider) do
    case HTTPFake.get(provider) do
      {:ok, %HTTPFake.Response{state_code: 200, body: body}} ->
        extract_products(body)
      _ ->
        {:error, :http_error}
    end
  end

  defp extract_products(body) do
    case Poison.decode(body) do
      {:ok, body} -> {:ok, body}
      _ -> {:error, :unable_to_parse}
    end
  end
end
