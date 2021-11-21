defmodule CcgWeb.LobbyViewLive do
  use CcgWeb, :live_view
  alias Ccg.Lobby
  alias CcgWeb.Auth
  alias Phoenix.PubSub

  @impl true
  # Create new lobby and redirect
  def mount(_params, session, %{assigns: %{live_action: :new}} = socket) do
    {:ok, user} = Auth.user(session)
    {name, _pid} = Lobby.Registry.new_lobby(%{gamemode: :constructed, created_by: user})
    {:ok, redirect(socket, to: Routes.lobby_view_path(socket, :get_lobby, name))}
  end
  def mount(
    %{"lobbyname" => name},
    session,
    %{assigns: %{live_action: :get_lobby}} = socket
  ) do
    lobby = Lobby.Registry.by_name(name)
    case lobby do
      {:ok, lobby} ->
        socket = socket
        |> assign(:lobby, Lobby.Server.lobby_info(lobby))
        |> Auth.assign_user(session)
        {:ok, socket}
      _ -> {:ok, redirect(socket, to: Routes.lobby_view_path(socket, :index))}
    end
  end
  def mount(_p, session, %{assigns: %{live_action: :index}} = socket) do
    if connected?(socket) do
      PubSub.subscribe(Ccg.PubSub, "lobbylist")
    end

    lobbies = Lobby.Registry.all_lobbies()
      |> Enum.map(&Lobby.Registry.by_name/1)
      |> Enum.map(fn {:ok, lobby} -> lobby end)
      |> Enum.map(&Lobby.Server.lobby_info/1)

    socket = socket
    |> assign(:lobbies, lobbies)
    |> Auth.assign_user(session)

    {:ok, socket}
  end

  @impl true
  def handle_event("kill_lobby", _value, socket) do
    user_id = socket.assigns.user.id
    ^user_id = socket.assigns.lobby.created_by.id
    name = socket.assigns.lobby.id
    IO.puts "Destroying lobby with name #{name}"
    Lobby.Registry.kill_lobby(name)
    {:noreply, push_redirect(socket, to: Routes.lobby_view_path(socket, :index))}
  end

  @impl true
  def handle_info({:new_lobby, lobby_info}, socket) do
    socket = update(socket, :lobbies, fn lobbies -> [lobby_info | lobbies] end)
    {:noreply, socket}
  end
  def handle_info({:dropped_lobby, name}, socket) do
    socket = update(socket, :lobbies, &Enum.filter(&1, fn lob -> lob.id != name end))
    {:noreply, socket}
  end
  def handle_info(_msg, socket), do: {:noreply, socket}
end
