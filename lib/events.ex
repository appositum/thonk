defmodule Thonk.Events do
  use Alchemy.Events
  require Logger

  Events.on_ready(:ready)
  def ready(_, _) do
    Logger.info("Bot ready")
  end
end
