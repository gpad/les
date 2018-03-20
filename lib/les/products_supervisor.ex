defmodule Les.ProductsSupervisor do
  use Supervisor

  def start_fetcher(provider) do
    Les.ProductsFetcherSupervisor.start_fetcher(provider)
  end

  def remove_fetcher(pid) do
    Les.ProductsFetcherSupervisor.remove_fetcher(pid)
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    children = [
      worker(Les.Products, []),
      supervisor(Les.ProductsFetcherSupervisor, []),
    ]
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
