defmodule Thonk.Comment do
  use Alchemy.Cogs

  @doc """
  Gets a random comment from brazilian porn on xvideos.

  Inspired by `https://github.com/ihavenonickname/bot-telegram-comentarios-xvideos`.
  """
  Cogs.def comment do
    Cogs.say("**Pesquisando um comentário...**")

    {title, %{"c" => content, "n" => author}} = get_comment()
    title   = HtmlEntities.decode(title)
    author  = HtmlEntities.decode(author)
    content = HtmlEntities.decode(content)

    reply = ~s(**Título:**\n`#{title}`\n\n**#{author} comentou:**\n`#{content}`)
    Cogs.say(reply)
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
    info = res.body
    |> Poison.decode!()
    |> Map.get("comments")
    |> Enum.at(0)

    # Handle empty comments
    case info do
      nil ->
        get_comment()
      _ ->
        {title, Map.take(info, ["c", "n"])}
    end
  end
end
