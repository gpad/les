defmodule Les do
  @moduledoc """
  Les keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def ring_status() do
    {:ok, ring} = :riak_core_ring_manager.get_my_ring
    :riak_core_ring.pretty_print(ring, [:legend])
  end

  def services() do
    :riak_core_node_watcher.services()
  end
end
