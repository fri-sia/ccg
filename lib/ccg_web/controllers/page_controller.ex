defmodule CcgWeb.PageController do
  use CcgWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
