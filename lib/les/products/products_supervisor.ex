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
      supervisor(Les.Products.FetcherSupervisor, []),
      worker(Les.Products, []),
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
