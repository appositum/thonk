defmodule Thonk.Voice do
  use Alchemy.Cogs
  alias Alchemy.Voice
  # TODO: `leave` command

  @doc """
  Plays a song in a chat by the youtube URL.
  """
  Cogs.def play(url) do
    {:ok, guild} = Cogs.guild()
    default_voice_channel = Enum.find(guild.channels, &match?(%{type: :voice}, &1))

    Voice.join(guild.id, default_voice_channel.id)
    Voice.play_url(guild.id, url)
    Cogs.say("Now playing #{url}")
  end
end
