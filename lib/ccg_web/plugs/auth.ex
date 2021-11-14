defmodule CcgWeb.Plugs.Auth do
  import Plug.Conn
  alias Phoenix.Token
  alias Ccg.Repo

  def init(default), do: default

  def call(conn, _default) do
    conn = fetch_cookies(conn)
    user_token = conn.cookies["ccg-user-token"]
    user_id_res = Token.verify CcgWeb.Endpoint,
      Application.get_env(:ccg, :user_token_signing_salt),
      user_token
    case user_id_res do
      {:ok, user_id} ->
        user = Repo.get(Ccg.Account.User, user_id)
        assign(conn, :user, user)
      {:error, _t} ->
        conn
        |> Plug.Conn.delete_resp_cookie("ccg-user-token")
        |> assign(:user, nil)
    end
  end
end
