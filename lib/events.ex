defmodule Thonk.Events do
  use Alchemy.Events
  alias Alchemy.{Cache, Cogs}
  require Logger
  require Alchemy.Embed, as: Embed

  @colors [
    0x75B1FF, # blue
    0xFF7DB6, # pink
    0x8FFFA7, # green
    0xFF9E54, # orange
    0xA159FF, # purple
    0xFFFF99, # yellow1
    0xFFF566, # yellow2
    0xFFF12E, # yellow3
    0xFF6161, # red1
    0xFF5460, # red2
    0xBA7049, # brown
  ]

  Events.on_ready(:ready)
  def ready(_, _) do
    me = "#{Cache.user.username}##{Cache.user.discriminator} (#{Cache.user.id})"
    Logger.info("Logged in as #{me}")
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

        ~s/Command "#{prefix <> command}" called by <@#{id}> (#{username}##{tag})/
        |> Logger.info()
      end
    end
  end

  Events.on_message(:ohno)
  def ohno(message) do
    if message.content == "oh no" && message.author.id != Cache.user.id do
      %Embed{}
      |> Embed.image("https://www.raylu.net/f/ohno/ohno#{Enum.random(1..53)}.png")
      |> Embed.color(Enum.random(@colors))
      |> Embed.send()
    end
  end
end
