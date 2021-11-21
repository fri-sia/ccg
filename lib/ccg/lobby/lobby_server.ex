defmodule Ccg.Lobby.ServerState do
  @enforce_keys [:id, :gamemode, :created_by]
  defstruct [:id, :gamemode, :created_by,  inhabitants: %{}, settings: %{}]
end

defmodule Ccg.Lobby.Server do
  use GenServer
  alias Ccg.Lobby.ServerState

  @impl true
  def init(fields) do
    {:ok, struct(ServerState, fields)}
  end

  @impl true
  def handle_call(:lobby_info, _from, state) do
    {:reply, state, state}
  end

  def start(state) do
    GenServer.start(__MODULE__, state, [])
  end

  def lobby_info(server) do
    GenServer.call(server, :lobby_info)
  end

end
