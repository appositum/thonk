defmodule Thonk.Basic do
  use Alchemy.Cogs
  alias Thonk.Utils
  alias Alchemy.{Client, Voice}
  require Alchemy.Embed, as: Embed

  @yellow 0xfac84b

  Cogs.def help do
    commands = Cogs.all_commands()
    |> Map.keys()
    |> Enum.join("\n")

    %Embed{color: @yellow, title: "All available commands", description: commands}
    |> Embed.send()
  end

  @doc """
  Gets a random xkcd comic.
  """
  Cogs.def xkcd do
    Cogs.say("https://xkcd.com/#{Enum.random(1..1964)}")
  end

  @doc """
  Roll dice.
  """
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
        numbers = Stream.repeatedly(fn -> Enum.random(1..6) end)
        |> Enum.take(times)
        |> Enum.join(", ")

        ":game_die: You rolled **#{times}** times!\n**#{numbers}**"
        |> Utils.check_exceed()
        |> Cogs.say()
    end
  end

  @doc """
  oh no
  """
  Cogs.def ohno do
    Client.send_message(message.channel_id, "oh no", file: "lib/assets/ohno.png")
  end

  @moduledoc """
  Plays a gemidao in a voice channel.
  """
  Cogs.def gemidao do
    {:ok, guild} = Cogs.guild()
    voice_channel = Enum.find(guild.channels, &match?(%{type: :voice}, &1))

    Voice.join(guild.id, voice_channel.id)
    Voice.play_file(guild.id, "lib/assets/gemidao.mp3")
  end

  @doc """
  Gets a random comment from brazilian porn on xvideos.

  Inspired by `https://github.com/ihavenonickname/bot-telegram-comentarios-xvideos`.
  """
  Cogs.def xvideos do
    {title, %{"c" => content, "n" => author}} = get_comment()
    title   = Utils.escape(title)
    author  = Utils.escape(author)
    content = Utils.escape(content)

    %Embed{color: 0xe80000, title: "XVideos"}
    |> Embed.field("Título:", "**`#{title}`**")
    |> Embed.field("#{author} comentou:", "**`#{content}`**")
    |> Embed.send()
  end

  @spec fetch_page(number) :: {String.t, String.t}
  defp fetch_page(page_number) do
    res = HTTPoison.get!("https://www.xvideos.com/porn/portugues/#{page_number}")
    res.body
    |> Floki.parse()
    |> Floki.find(".thumb-block > p > a")
    |> Enum.map(fn {_tag, info, _title} ->
      [{_, href}, {_, title}] = info
      [_, video_ref] = Regex.run(~r{/video(\d+)/.*}, href)
      {title, video_ref}
    end)
  end

  @spec get_comment :: {String.t, map}
  defp get_comment do
    videos = fetch_page(Enum.random(1..40))
    [{title, video_ref}] = Enum.take_random(videos, 1)

    res = HTTPoison.get!("https://www.xvideos.com/video-get-comments/#{video_ref}/0")
    comment = res.body
    |> Poison.decode!()
    |> Map.get("comments")
    |> Enum.take_random(1)

    # Handle empty comments
    case comment do
      [] ->
        get_comment()
      [c] ->
        {title, Map.take(c, ["c", "n"])}
    end
  end
end
