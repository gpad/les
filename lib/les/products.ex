defmodule Les.Products do
  use GenServer
  require Logger
  alias Les.Products.State

  @providers ~w(
    https://provider1.it/products
    https://provider2.it/products
    https://provider3.it/products
  )

  defmodule State do
    defstruct [products: %{}, pending_requests: %{}, providers: %{}]
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    delay = trunc(60_000 / length(@providers))
    Enum.reduce(@providers, 0, fn provider, acc ->
      :timer.apply_after(acc, __MODULE__, :add_provider, [provider])
      acc + delay
    end)
    {:ok, %State{}}
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def add_provider(host) do
    GenServer.call(__MODULE__, {:add_provider, host})
  end

  def remove_provider(host) do
    GenServer.call(__MODULE__, {:remove_provider, host})
  end

  def add_products(provider, products) do
    GenServer.cast(__MODULE__, {:add_products, provider, products})
  end

  def handle_call({:get, id}, _from, state) do
    ret = case Map.fetch(state.products, id) do
      :error -> Logger.warn("Unable to find products with id: #{inspect id}")
      ret -> ret
    end
    {:reply, ret, state}
  end

  def handle_call(:all, _from, state) do
    ret = state.products |> Enum.map(fn {_, v} -> v end)
    {:reply, ret, state}
  end

  def handle_call({:add_provider, host}, _from, state) do
    new_state = add_provider(state, host)
    {:reply, :ok, new_state}
  end

  def handle_call({:remove_provider, host}, _from, state) do
    new_state = remove_provider(state, host)
    {:reply, :ok, new_state}
  end

  def handle_cast({:add_products, provider, result}, state) do
    new_state = case result do
      {:ok, %{"products" => products}} ->
        add_products(state, provider, products)
      {:error, reason} ->
        Logger.warn("Received error: #{inspect reason} from #{provider}")
        state
    end
    {:noreply, new_state}
  end

  defp add_provider(%State{providers: providers}=state, host) do
    case Map.fetch(providers, host) do
      {:ok, _} ->
        state
      _ ->
        {:ok, pid} = Les.Products.Supervisor.start_fetcher(host)
        %State{state | providers: Map.merge(providers, %{host => pid})}
    end
  end

  defp remove_provider(%State{providers: providers}=state, host) do
    case Map.pop(providers, host) do
      {nil, _} ->
        Logger.warn("Unable to remove provider #{host}. It doesn't exist.")
        state
      {pid, new_providers} ->
        Les.Products.Supervisor.remove_fetcher(pid)
        %State{state | providers: new_providers}
    end
  end

  defp add_products(%State{products: products}=state, provider, products_to_add) do
    ps1 = map_by_ext_key(products, provider)
    new_products = Enum.reduce(products_to_add, products, fn (%{"id" => ext_id}=p, acc) ->
      product = Map.get_lazy(ps1, ext_id, fn ->
        %Les.Products.Product{
          id: UUID.uuid4(),
          description: p["description"],
          provider: provider,
          ext_id: ext_id,
          price: p["value"],
          qty: p["qty"],
        }
      end)
      Map.put(acc, product.id, product)
    end)
    %State{state | products: new_products}
  end

  defp map_by_ext_key(products, provider) do
    Enum.reduce(products, %{}, fn {_, prod}, acc ->
      if prod.provider == provider do
        Map.put(acc, prod.ext_id, prod)
      else
        acc
      end
    end)
  end

end
