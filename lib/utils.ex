defmodule Thonk.Utils do
  alias Alchemy.Permissions

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

  @spec admin_check(%Alchemy.Guild{}, String.t) :: boolean
  def admin_check(guild, user_id) do
    member = guild.members
    |> Enum.find(&(&1.user.id == user_id))

    roles = guild.roles
    |> Enum.filter(fn role -> role.id in member.roles end)
    |> Enum.map(fn role ->
      role.permissions
      |> Permissions.contains?(:administrator)
    end)

    true in roles
  end

  @doc """
  Check if some string exceeds discod's characters limit (2000).
  """
  def exceed_check(input) do
    size = String.length(input)

    cond do
      size > 2000 ->
        res = HTTPoison.post!("https://hastebin.com/documents", input)
        link = res.body
        |> Poison.decode!()
        |> Map.get("key")

        ":warning: The command output exceeded the characters limit! (`#{size}/2000`)\nYou can check it out here: https://hastebin.com/#{link}"
      true ->
        input
    end
  end

  @spec escape(String.t) :: String.t
  def escape(string) do
    Regex.replace(~r{</?(a|A).*?>}, string, "")
    |> HtmlEntities.decode()
    |> String.replace("<br />", "\n")
  end
end
