defmodule Thonk.Events do
  use Alchemy.Events
  alias Alchemy.Cogs
  require Logger

  Events.on_ready(:ready)
  def ready(_, _) do
    Logger.info("Bot ready")
  end

  Events.on_message(:on_message)
  def on_message(message) do
    prefix = Application.get_env(:thonk, :prefix)

    if String.starts_with?(message.content, prefix) do
      command = message.content
      |> String.split()
      |> List.first()
      |> String.graphemes()
      |> Enum.drop(2)
      |> Enum.join()

      if command in Map.keys(Cogs.all_commands()) do
        id = message.author.id
        username = message.author.username
        tag = message.author.discriminator

        ~s/Command "#{prefix <> command}" called by <@#{id}> (#{username}\##{tag})/
        |> Logger.info()
      end
    end
  end
end
