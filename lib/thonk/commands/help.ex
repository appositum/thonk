defmodule Thonk.Commands.Help do
  use Alchemy.Cogs
  Cogs.group("help")

  Cogs.def somecommand do
    Cogs.say("Hello")
  end

  # TODO
end
