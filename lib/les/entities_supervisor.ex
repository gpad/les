defmodule Les.EntitiesSupervisor do
  use Supervisor

  def start_user(user_id, opts \\ [products: Les.Products]) do
    Supervisor.start_child(__MODULE__, %{
      id: Les.UserEntity.get_entity_name(user_id),
      start: {Les.UserEntity, :start_link, [user_id, opts]}
    })
  end

  def find_user(user_id) do
    child_id = Les.UserEntity.get_entity_name(user_id)
    children = Supervisor.which_children(__MODULE__)
      |> Enum.filter(fn {id, _, _, _} -> id == child_id end)
    case children do
      [{_, pid, _, _}] -> {:ok, pid}
      [] -> start_user(user_id)
    end
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
