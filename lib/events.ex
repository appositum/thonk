defmodule Thonk.Events do
  use Alchemy.Events
  require Logger

  Events.on_ready(:ready)
  def ready(_, _) do
    Logger.info("Bot ready")
  end

  Events.on_message(:inspect)
  def inspect(message) do
    IO.inspect(message.content)
  end
end
