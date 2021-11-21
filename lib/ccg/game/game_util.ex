defmodule Ccg.Game.Util do
  def gamemode_tostr(gamemode) do
    case gamemode do
      :constructed -> "Constructed"
      :draft -> "Draft"
    end
  end
end
