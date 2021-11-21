defmodule Ccg.Lobby.Registry do
  use GenServer
  alias Ccg.Lobby
  alias Phoenix.PubSub

  # Server callbacks
  @impl true
  def init(_arg) do
    {:ok, {%{}, %{}}}
  end


  @impl true
  def handle_call({:lookup, name}, _from, {names, refs}) do
    {:reply, Map.fetch(names, name), {names, refs}}
  end

  @impl true
  def handle_call({:new, state}, _from, {names, refs}) do
    name = random_name(names)
    {:ok, pid} = Lobby.Server.start(Map.put(state, :id, name))
    ref = Process.monitor(pid)
    lobby_info = Lobby.Server.lobby_info(pid)
    PubSub.broadcast Ccg.PubSub, "lobbylist", {:new_lobby, lobby_info}
    {:reply, {name, pid}, {
      Map.put(names, name, pid),
      Map.put(refs, ref, name)
    }}
  end

  @impl true
  def handle_call(:all, _from, {names, refs}) do
    names_list = Map.keys(names)
    {:reply, names_list, {names, refs}}
  end

  @impl true
  def handle_cast({:kill_lobby, name}, {names, refs}) do
    {lobby, names} = Map.pop(names, name)
    GenServer.stop(lobby)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    PubSub.broadcast Ccg.PubSub, "lobbylist", {:dropped_lobby, name}
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  # Client api
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def new_lobby(opts) do
    GenServer.call(__MODULE__, {:new, opts})
  end

  def by_name(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def kill_lobby(name) do
    GenServer.cast(__MODULE__, {:kill_lobby, name})
  end

  def all_lobbies() do
    GenServer.call(__MODULE__, :all)
  end

  # Privates
  defp random_name(existing_names) do
    name = Base.encode64(:rand.bytes(8))
    if Map.has_key?(existing_names, name),
      do: random_name(existing_names),
      else: name
  end
end
