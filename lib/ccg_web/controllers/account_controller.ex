defmodule CcgWeb.AccountController do
  use CcgWeb, :controller
  alias Ccg.Repo
  alias Ccg.Account.User
  alias Phoenix.Token

  def index(conn, _params) do
    case conn.assigns.user do
      nil -> redirect(conn, to: Routes.account_path(conn, :login))
      _user -> render(conn, "index.html")
    end
  end

  def login(conn,_params) do
    render conn, "login.html",
      token: [value: get_csrf_token()]
  end

  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("ccg-user-token")
    |> redirect(to: Routes.account_path(conn, :index))
  end

  def verify_login(conn, params) do
    user = Repo.get_by(User, email: params["email"])
    verified = verify_pass(user, params["password"])

    case verified do
      {:ok, user} -> setup_user(conn, user)
      {:error, _err} ->
        conn
          |> put_flash(:error, "Invalid login")
          |> render("login.html", token: [value: get_csrf_token()])
    end
  end

  # Private functions
  defp setup_user(conn, user) do
    token = Token.sign(CcgWeb.Endpoint, Application.get_env(:ccg, :user_token_signing_salt), %{
      "user_id" => user.id
    })
    cookied_conn = conn
    |> put_session("ccg-user-token", token)
    cookied_conn |> redirect(to: Routes.account_path(cookied_conn, :index))
  end

  defp verify_pass(nil, _password), do: {:error, "Invalid login"}
  defp verify_pass(user, password), do: Bcrypt.check_pass(user, password)
end
