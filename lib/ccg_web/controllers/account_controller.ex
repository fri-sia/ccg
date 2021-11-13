defmodule CcgWeb.AccountController do
  use CcgWeb, :controller
  alias Ccg.Repo
  alias Ccg.Account.User

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn,_params) do
    render conn, "login.html", token: [value: get_csrf_token()]
  end

  def verify_login(conn, params) do
    user = Repo.get_by!(User, email: params["email"])
    verified = Bcrypt.check_pass(user, params["password"])

    render conn, "login.html", token: [value: get_csrf_token()]
  end
end
