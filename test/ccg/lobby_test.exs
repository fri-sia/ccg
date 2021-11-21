defmodule Ccg.LobbyTest do
  use ExUnit.Case, async: true
  alias Ccg.Lobby

  defp mk_lobby() do
    Lobby.Registry.new_lobby(%{
      gamemode: :draft,
      created_by: 0
    })
  end

  setup do
    registry = Lobby.Registry
    %{registry: registry}
  end

  test "Create new lobbies", %{registry: registry} do
    {name1, _p1} = mk_lobby()
    {name2, _p2} = mk_lobby()
    assert (name1 !== name2)
  end

  test "Check if newly created lobbies can be looked up", %{registry: registry} do
    {name, lobby} = mk_lobby()
    {:ok, ^lobby} = Lobby.Registry.by_name(name)
  end

  test "Remove lobby from registry on exit", %{registry: registry} do
    {name, lobby} = mk_lobby()
    GenServer.stop(lobby)
    :error = Lobby.Registry.by_name(name)
  end

  test "Remove lobby from registry on lobby crash", %{registry: registry} do
    {name, lobby} = mk_lobby()
    GenServer.stop(lobby, :shutdown)
    :error = Lobby.Registry.by_name(name)
  end
end
