defmodule Les.ProductsFetcherSupervisor do
  use Supervisor

  def start_fetcher(provider) do
    Supervisor.start_child(__MODULE__, [provider])
  end

  def remove_fetcher(pid) do
    Supervisor.terminate_child(__MODULE__, pid)
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    Supervisor.init([
      worker(Les.ProductsFetcher, [])
      ], strategy: :simple_one_for_one)
  end
end
