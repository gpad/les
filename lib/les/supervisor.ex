defmodule Les.Supervisor do
  use Supervisor

  def start_link do
    # riak_core appends _sup to the application name.
    Supervisor.start_link(__MODULE__, [], [name: :les_sup])
  end

  def init(_args) do
    children = [
      # supervisor(Les.WriteFsmSupervisor, []),
      # supervisor(Les.GetFsmSupervisor, []),
      # supervisor(Les.CoverageFsmSupervisor, []),
      worker(:riak_core_vnode_master, [Les.VNode], id: Les.VNode_master_worker)
    ]
    supervise(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 10)
  end

end
