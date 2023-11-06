defmodule Thonk.Utils do
  @moduledoc """
  Utilities functions to be used on the bot's Cogs.
  """
  require Alchemy.Embed, as: Embed

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
  @spec message_exceed?(String.t) :: boolean
  def message_exceed?(input) do
    cond do
      String.length(input) > 2000 -> true
      true -> false
    end
  end

  @doc """
  Check if some string exceeds discord's characters limit (2000).
  If so, returns a warning string with a hastebin link containing the output.
  """
  @spec message_exceed(String.t) :: String.t
  def message_exceed(input) do
    size = String.length(input)

    cond do
      size > 2000 ->
        res = HTTPoison.post!("https://hastebin.com/documents", input)
        link = res.body
        |> Poison.decode!()
        |> Map.get("key")

        ":warning: **The command output exceeded the characters limit! (`#{size}/2000`)\nYou can check it out here: https://hastebin.com/#{link}**"
      true ->
        input
    end
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
  def get_comment do
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

  @spec escape(String.t) :: String.t
  def escape(string) do
    Regex.replace(~r{</?(a|A).*?>}, string, "")
    |> HtmlEntities.decode()
    |> String.replace("<br />", "\n")
  end

  @doc """
  Generate a random color in hexadecimal.

  ## Examples
      iex> Thonk.Utils.color_random()
      "FCFB5E"
  """
  def color_random do
    color_random([])
    |> Enum.map(&to_string/1)
    |> Enum.join()
  end

  defp color_random(list) do
    case length(list) do
      6 ->
        list
      _ ->
        hex_digit = Enum.random(0..15) |> Integer.to_charlist(16)
        color_random([hex_digit | list])
    end
  end

  @spec color_embed(String.t) :: %Embed{}
  def color_embed(color_hex) do
    color = CssColors.parse!(color_hex) # color struct

    hue = trunc CssColors.hsl(color).hue
    lightness = trunc CssColors.hsl(color).lightness * 100
    saturation = trunc CssColors.hsl(color).saturation * 100
    hsl = "#{hue}, #{lightness}%, #{saturation}%"
    rgb = "#{trunc(color.red)}, #{trunc(color.green)}, #{trunc(color.blue)}"

    %Mogrify.Image{path: "color.jpg", ext: "jpg"}
    |> Mogrify.custom("size", "80x80")
    |> Mogrify.canvas(to_string(color))
    |> Mogrify.create(path: "./lib/assets/")

    # Remove "#" symbol
    color_hex = to_string(color)
    |> String.graphemes()
    |> Enum.drop(1)
    |> Enum.join()

    {color_integer, _} = Code.eval_string("0x#{color_hex}") # color number for the embed
    %Embed{color: color_integer, title: to_string(color)}
    |> Embed.field("RGB", rgb)
    |> Embed.field("HSL", hsl)
    |> Embed.thumbnail("attachment://color.jpg")
  end
end
