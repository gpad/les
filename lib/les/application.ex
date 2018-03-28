defmodule Les.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(Les.Repo, []),
      supervisor(LesWeb.Endpoint, []),
      supervisor(Les.Supervisor, []),
      supervisor(Les.EntitiesSupervisor, []),
      supervisor(Les.Products.Supervisor, []),
      supervisor(Les.PaymentProcessorSupervisor, []),
    ]
    opts = [strategy: :one_for_one, name: Les.Supervisor]
    ret = Supervisor.start_link(children, opts)

    case ret do
      {:ok, pid} ->
        :ok = :riak_core.register(vnode_module: Les.EntityVNode)
        :ok = :riak_core_node_watcher.service_up(Les.EntityService, self())
        {:ok, pid}
      {:error, reason} ->
        Logger.error("Unable to start Les supervisor because: #{inspect reason}")
    end


  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
