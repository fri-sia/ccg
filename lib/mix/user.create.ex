alias Ccg.Repo
alias Ccg.Account.User

defmodule Mix.Tasks.User.Create do
  use Mix.Task

  @requirements ["app.config"]
  @shortdoc "create a new user"

  @impl Mix.Task
  def run(command_line_args) do
    Mix.Task.run("app.start")

    IO.puts "Creating a new user"
    [email, password] = command_line_args
    IO.puts "Using email '#{email}'"
    IO.puts "Using password '#{password}'"

    password_hash = Bcrypt.hash_pwd_salt(password)
    Repo.insert!(User.changeset(%User{
      email: email,
      password_hash: password_hash
    }, %{}))

  end
end
