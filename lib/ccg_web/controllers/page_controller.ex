defmodule CcgWeb.PageController do
  use CcgWeb, :controller

  def index(conn, _params) do
    lobby_path = Routes.lobby_view_path(conn, :index)
    conn = assign(conn, :lobby_path, lobby_path)
    render(conn, "index.html")
  end
end
