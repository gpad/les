defmodule Les.Products.Supervisor do
  use Supervisor

  def start_fetcher(provider) do
    Les.Products.FetcherSupervisor.start_fetcher(provider)
  end

  def remove_fetcher(pid) do
    Les.Products.FetcherSupervisor.remove_fetcher(pid)
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    import Supervisor.Spec

    children = [
      worker(Les.Products, []),
      supervisor(Les.Products.FetcherSupervisor, []),
    ]
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
