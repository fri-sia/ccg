defmodule Ccg.Lobby.ServerState do
  @enforce_keys [:id, :gamemode, :created_by]
  defstruct [:id, :gamemode, :created_by,
    inhabitants: %{},
    live_connections: %{},
    messages: [],
    settings: %{}]
end

defmodule Ccg.Lobby.Server do
  use GenServer
  use Timex
  alias Ccg.Lobby.ServerState
  alias Phoenix.PubSub

  @impl true
  def init(fields) do
    {:ok, struct(ServerState, fields)}
  end

  @impl true
  def handle_call(:lobby_info, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:join, user}, {pid, _from}, state) do
    ref = Process.monitor(pid)
    state = Map.update!(state, :live_connections, &Map.put(&1, ref, user.id))
    case Map.has_key?(state.inhabitants, user.id) do
      true -> {:reply, {:ok, :already_in}, state}
      false ->
        msg = {:system_msg, Timex.now(), "User #{user.name} joined"}
        state = state
          |> Map.update!(:inhabitants, &Map.put(&1, user.id, user))
          |> Map.update!(:messages, &List.insert_at(&1, 0, msg))

        PubSub.broadcast(Ccg.PubSub, "lobbylist", {:updated_lobby, state})
        PubSub.broadcast(Ccg.PubSub, "lobby:#{state.id}", {:lobby, :user_joined, state})
        PubSub.broadcast(Ccg.PubSub, "lobby:#{state.id}", {:lobby, :new_msg, msg})
        {:reply, {:ok, :joined}, state}
    end
  end

  @impl true
  def handle_cast({:chat_msg, user, msg_text}, state) do
    msg = {{:user, user}, Timex.now(), msg_text}
    state = Map.update!(state, :messages, fn msgs -> [msg | msgs] end)
    PubSub.broadcast(Ccg.PubSub, "lobby:#{state.id}", {:lobby, :new_msg, msg})
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    user_id = Map.get(state.live_connections, ref)
    state = Map.update!(state, :live_connections, &Map.delete(&1, ref))
    has_other_connection? = state.live_connections
      |> Map.values()
      |> Enum.any?(fn uid -> user_id === uid end)
    state = case has_other_connection? do
      true -> state
      false -> Map.update!(state, :inhabitants, &Map.delete(&1, user_id))
    end
    PubSub.broadcast(Ccg.PubSub, "lobbylist", {:updated_lobby, state})
    PubSub.broadcast(Ccg.PubSub, "lobby:#{state.id}", {:lobby, :user_left, state})
    {:noreply, state}
  end

  def start(state) do
    GenServer.start(__MODULE__, state, [])
  end

  def lobby_info(server) do
    GenServer.call(server, :lobby_info)
  end

  def join(server, user) do
    GenServer.call(server, {:join, user})
  end

  def send_chat_message(server, user, msg) do
    GenServer.cast(server, {:chat_msg, user, msg})
  end

end
