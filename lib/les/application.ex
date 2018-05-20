defmodule Les.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(Les.Repo, []),
      supervisor(LesWeb.Endpoint, []),
      supervisor(Les.EntitiesSupervisor, []),
      supervisor(Les.Products.Supervisor, []),
      supervisor(Les.PaymentProcessorSupervisor, []),
    ]
    opts = [strategy: :one_for_one, name: Les.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
