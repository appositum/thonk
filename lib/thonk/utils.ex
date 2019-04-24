defmodule Thonk.Utils do
  @moduledoc """
  Utilities functions to be used on the bot's Cogs.
  """

  @type message :: String.t()
  @type video_id :: String.t()
  @type video_title :: String.t()
  @type video_info :: {video_title, video_id}
  @type comment_info :: map

  def uptime do
    {time, _} = :erlang.statistics(:wall_clock)
    min = div(time, 1000 * 60)
    {hours, min} = {div(min, 60), rem(min, 60)}
    {days, hours} = {div(hours, 24), rem(hours, 24)}

    Stream.zip([min, hours, days], ["m", "h", "d"])
    |> Enum.reduce("", fn
      {0, _glyph}, acc -> acc
      {t, glyph}, acc -> " #{t}" <> glyph <> acc
    end)
  end

  @doc """
  Check if some string exceeds discord's characters limit (2000).
  Returns `true` of `false`.
  """
  @spec message_exceed?(message) :: boolean
  def message_exceed?(s), do: String.length(s) > 2000

  @doc """
  Check if some string exceeds discord's characters limit (2000).
  If so, returns a warning string with a hastebin link containing the output.
  """
  @spec message_exceed(message) :: message
  def message_exceed(input) do
    size = String.length(input)

    cond do
      size > 2000 ->
        res = HTTPoison.post!("https://hastebin.com/documents", input)

        link =
          res.body
          |> Poison.decode!()
          |> Map.get("key")

        ":warning: **The command output exceeded the characters limit!" <>
          "(`#{size}/2000`)\nYou can check it out here: https://hastebin.com/#{link}**"

      true ->
        input
    end
  end

  @spec fetch_page(number) :: video_info
  def fetch_page(page_number) do
    res = HTTPoison.get!("https://www.xvideos.com/lang/portugues/#{page_number}")

    res.body
    |> Floki.parse()
    |> Floki.find(".thumb-under > p > a")
    |> Enum.map(fn {_tag, info, _title} ->
      [{_, href}, {_, title}] = info
      [_, video_ref] = Regex.run(~r{/video(\d+)/.*}, href)
      {title, video_ref}
    end)
  end

  @spec get_comment :: {video_title, comment_info}
  def get_comment do
    videos = fetch_page(Enum.random(1..40))
    [{title, video_ref}] = Enum.take_random(videos, 1)

    res = HTTPoison.get!("https://www.xvideos.com/threads/video-comments/get-posts/top/#{video_ref}/0/0")

    comment =
      res.body
      |> Poison.decode!()
      |> Map.get("posts")
      |> Map.get("posts")
      |> Enum.take_random(1)

    # Handle empty comments
    case comment do
      [] ->
        get_comment()

      [{_id, c}] ->
        {title, Map.take(c, ["message", "name", "pic", "date"])}
    end
  end

  @spec escape(String.t()) :: String.t()
  def escape(string) do
    Regex.replace(~r{</?(a|A).*?>}, string, "")
    |> HtmlEntities.decode()
    |> String.replace("<br />", "\n")
  end
end
