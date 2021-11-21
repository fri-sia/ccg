defmodule CcgWeb.PageControllerTest do
  use CcgWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "CCG"
  end
end
