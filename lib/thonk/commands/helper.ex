defmodule Thonk.Commands.Helper do
  use Alchemy.Cogs
  Cogs.group("help")

  Cogs.def somecommand do
    Cogs.say("Hello")
  end

  def general do
    commands =
      Cogs.all_commands()
      |> Map.keys()
      |> Enum.join("\n")
  end

  # TODO
end
