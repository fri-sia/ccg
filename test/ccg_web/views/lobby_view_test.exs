defmodule CcgWeb.LobbyViewTest do
  use CcgWeb.ConnCase

  test "get lobby index", %{conn: conn} do
    conn = get(conn, Routes.lobby_view_path(conn, :index))
    assert html_response(conn, 200) =~ "Lobbies"
  end
end
