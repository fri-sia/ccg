defmodule CcgWeb.Plugs.Auth do
  import Plug.Conn
  alias Phoenix.Token
  alias Ccg.Repo

  def init(default), do: default

  def call(conn, _default) do
    conn = fetch_cookies(conn)
    user_token = get_session(conn, "ccg-user-token")
    claims_res = Token.verify CcgWeb.Endpoint,
      Application.get_env(:ccg, :user_token_signing_salt),
      user_token
    case claims_res do
      {:ok, claims} ->
        user = Repo.get(Ccg.Account.User, claims["user_id"])
        assign(conn, :user, user)
      {:error, _t} ->
        conn
        |> Plug.Conn.delete_resp_cookie("ccg-user-token")
        |> assign(:user, nil)
    end
  end
end

defmodule CcgWeb.Auth do
  alias Phoenix.Token
  alias Ccg.Repo

  def user_id(session) do
    token = Map.get session, "ccg-user-token"
    claims = Token.verify CcgWeb.Endpoint,
      Application.get_env(:ccg, :user_token_signing_salt),
      token
    case claims do
      {:ok, claims} -> {:ok, claims["user_id"]}
      err -> err
    end
  end

  def user(session) do
    id = user_id(session)
    case id do
      {:ok, id} -> {:ok, Repo.get!(Ccg.Account.User, id)}
      err -> err
    end
  end

  def assign_user(socket, session) do
    {:ok, user} = user(session)
    Phoenix.LiveView.assign(socket, :user, user)
  end

  def sign_user(user) do
    sign_user_id(user.id)
  end

  def sign_user_id(user_id) do
    Token.sign(CcgWeb.Endpoint, Application.get_env(:ccg, :user_token_signing_salt), %{
      "user_id" => user_id
    })
  end
end
