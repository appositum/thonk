defmodule Thonk.Commands.Basic do
  @moduledoc false
  use Alchemy.Cogs
  alias Thonk.Utils
  alias Alchemy.{Client, Voice}
  require Logger
  require Alchemy.Embed, as: Embed

  @yellow 0xFAC84B

  Cogs.def ping do
    old = Time.utc_now()
    {:ok, message} = Cogs.say("Pong!")
    time = Time.diff(Time.utc_now(), old, :millisecond)
    Client.edit_message(message, "Pong! :ping_pong: took **#{time} ms**")
  end

  Cogs.def help do
    commands =
      Cogs.all_commands()
      |> Map.keys()
      |> Enum.join("\n")

    %Embed{color: @yellow, title: "All available commands", description: commands}
    |> Embed.send()
  end

  @doc """
  Information about the bot.
  """
  Cogs.def info do
    {:ok, app_version} = :application.get_key(:thonk, :vsn)
    {:ok, lib_version} = :application.get_key(:alchemy, :vsn)
    {:ok, guilds} = Client.get_current_guilds()

    infos = [
      {"Prefix", Application.get_env(:thonk, :prefix)},
      {"Version", "#{app_version}"},
      {"Elixir Version", System.version()},
      {"Library", "[Alchemy #{lib_version}](https://github.com/cronokirby/alchemy)"},
      {"Owner", "[appositum#1888](https://github.com/appositum)"},
      {"Guilds", "#{length(guilds)}"},
      {"Processes", "#{length(:erlang.processes())}"},
      {"Memory Usage", "#{div(:erlang.memory(:total), 1_000_000)} MB"}
    ]

    Enum.reduce(infos, %Embed{color: @yellow, title: "Thonk"}, fn {name, value}, embed ->
      Embed.field(embed, name, value, inline: true)
    end)
    |> Embed.thumbnail("http://i.imgur.com/6YToyEF.png")
    |> Embed.url("https://github.com/appositum/thonk")
    |> Embed.footer(text: "Uptime: #{Utils.uptime()}")
    |> Embed.send()
  end

  Cogs.def xkcd do
    Cogs.say("https://xkcd.com/#{Enum.random(1..1964)}")
  end

  Cogs.set_parser(:roll, &List.wrap/1)

  Cogs.def roll(times) do
    times =
      case Integer.parse(times) do
        {n, _} -> n
        :error -> 1
      end

    cond do
      times == 1 ->
        Cogs.say(":game_die: You rolled **#{Enum.random(1..6)}**!")

      true ->
        numbers =
          Stream.repeatedly(fn -> Enum.random(1..6) end)
          |> Enum.take(times)
          |> Enum.join(", ")

        ":game_die: You rolled **#{times}** times!\n**#{numbers}**"
        |> Utils.message_exceed()
        |> Cogs.say()
    end
  end

  @doc """
  Plays a gemidao do zap in a voice channel.
  """
  Cogs.def gemidao do
    case Cogs.guild() do
      {:ok, guild} ->
        voice_channel = Enum.find(guild.channels, &match?(%{type: :voice}, &1))
        Voice.join(guild.id, voice_channel.id)
        Voice.play_file(guild.id, "lib/assets/gemidao.mp3")

      {:error, reason} ->
        Logger.error(reason)
        Cogs.say(":exclamation: **#{reason}**")
    end
  end

  @doc """
  Gets a random comment from brazilian porn on xvideos.

  Inspired by `https://github.com/ihavenonickname/bot-telegram-comentarios-xvideos`.
  """
  Cogs.def xvideos do
    {title, %{"c" => content, "n" => author, "iu" => picture, "d" => date}} = Utils.get_comment()
    content = Utils.escape(content)

    {_, picture_link} =
      HTTPoison.get!("https://www.xvideos.com#{picture}").headers
      |> Enum.find(&match?({"Location", _picture_link}, &1))

    %Embed{color: 0xE80000}
    |> Embed.author(
      name: "XVideos",
      icon_url: "http://cdn.appaix.com/2015/0116/xvideos-23_84fec.png"
    )
    |> Embed.field("Título:", "**`#{title}`**")
    |> Embed.field("#{author} comentou:", "**`#{content}`**")
    |> Embed.thumbnail(picture_link)
    |> Embed.footer(
      text: "#{date} • Requested by #{message.author.username}##{message.author.discriminator}"
    )
    |> Embed.send()
  end
end
