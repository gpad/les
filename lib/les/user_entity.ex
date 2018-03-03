defmodule Les.UserEntity do
  use GenServer

  defmodule State do
    defstruct [:user]
  end

  def get_entity_name(id), do: :"user_entity_#{id}"

  def start_link(id) do
    GenServer.start_link(__MODULE__, [id], name: get_entity_name(id))
  end

  def create(attrs) do
    with {:ok, user} <- Les.Accounts.create_user(attrs),
         {:ok, _} <- Les.EntitiesSupervisor.start_user(user.id) do
      {:ok, user}
    else
      error -> error
    end
  end

  def init([id]) do
    user = Les.Accounts.get_user!(id)
    {:ok, %State{user: user}}
  end

  def update(pid, attrs) do
    GenServer.call(pid, {:update, attrs})
  end

  def get(pid) do
    GenServer.call(pid, {:get})
  end

  def handle_call({:update, attrs}, _form, state) do
    {res, new_state} =
      case Les.Accounts.update_user(state.user, attrs) do
        {:ok, user} -> {{:ok, user}, %{state | user: user}}
        res -> {res, state}
      end

    {:reply, res, new_state}
  end

  def handle_call({:get}, _form, state) do
    {:reply, state.user, state}
  end
end
