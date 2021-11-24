defmodule CcgWeb.LobbyViewTest do
  use CcgWeb.ConnCase, async: true

  @moduletag :requires_login

  test "get lobby index", %{conn: conn} do
    conn = get(conn, "/lobby")
    assert html_response(conn, 200) =~ "Lobbies"
  end
end
