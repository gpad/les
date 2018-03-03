defmodule Les.EntitiesSupervisor do
  use Supervisor

  def start_user(user_id) do
    Supervisor.start_child(__MODULE__, %{
      id: Les.UserEntity.get_entity_name(user_id),
      start: {Les.UserEntity, :start_link, [user_id]}
    })
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([], strategy: :one_for_one)
  end
end
