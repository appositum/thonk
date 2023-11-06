defmodule Thonk.Commands do
  use Alchemy.Cogs
  require Alchemy.Embed, as: Embed

  Cogs.def help do
    commands = Cogs.all_commands()
    |> Map.keys()
    |> Enum.join("\n")

    %Embed{color: 0xfac84b, title: "All available commands", description: commands}
    |> Embed.send()
  end

  @doc """
  Gets a random comment from brazilian porn on xvideos.

  Inspired by `https://github.com/ihavenonickname/bot-telegram-comentarios-xvideos`.
  """
  Cogs.def xvideos do
    {title, %{"c" => content, "n" => author}} = get_comment()
    title   = escape(title)
    author  = escape(author)
    content = escape(content)

    %Embed{color: 0xe80000, title: "XVideos"}
    |> Embed.field("Título:", "**`#{title}`**")
    |> Embed.field("#{author} comentou:", "**`#{content}`**")
    |> Embed.send()
  end

  @spec escape(String.t) :: String.t
  defp escape(string) do
    Regex.replace(~r{</?(a|A).*?>}, string, "")
    |> HtmlEntities.decode()
    |> String.replace("<br />", "\n")
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
