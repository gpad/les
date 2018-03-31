defmodule Les.EntitiesSupervisor do
  use Supervisor

  def start_local_user(user_id, opts \\ [products: Les.Products]) do
    Les.Accounts.get_user!(user_id)
    Supervisor.start_child(__MODULE__, %{
      id: Les.UserEntityServer.get_entity_name(user_id),
      start: {Les.UserEntityServer, :start_link, [user_id, opts]},
      # restart: :temporary
    })
  end

  def find_local_user(user_id) do
    child_id = Les.UserEntityServer.get_entity_name(user_id)
    children = Supervisor.which_children(__MODULE__)
      |> Enum.filter(fn {id, _, _, _} -> id == child_id end)
    case children do
      [{_, pid, _, _}] -> {:ok, pid}
      [] -> start_local_user(user_id)
    end
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
