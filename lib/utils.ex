defmodule Thonk.Utils do
  use Alchemy.Cogs
  alias Alchemy.{Cache, Client, Permissions, User}
  require Alchemy.Embed, as: Embed

  @yellow 0xfac84b

  Cogs.def help do
    commands = Cogs.all_commands()
    |> Map.keys()
    |> Enum.join("\n")

    %Embed{color: @yellow, title: "All available commands", description: commands}
    |> Embed.send()
  end

  Cogs.def set_prefix(new_prefix) do
    {:ok, guild} = Cogs.guild()

    case admin_check(guild, message.author.id) do
      false ->
        Cogs.say("You are not an administrator!")
      true ->
        Cogs.set_prefix(new_prefix)
        Application.put_env(:thonk, :prefix, new_prefix)
        Cogs.say("New prefix: `#{new_prefix}`")
    end
  end

  Cogs.def info do
    {:ok, app_version} = :application.get_key(:thonk, :vsn)
    {:ok, lib_version} = :application.get_key(:alchemy, :vsn)
    {:ok, guilds} = Client.get_current_guilds()

    infos = [
      {"Prefix", Application.get_env(:thonk, :prefix)},
      {"Version", "#{app_version}"},
      {"Elixir Version", System.version()},
      {"Library", "[Alchemy #{lib_version}](https://github.com/cronokirby/alchemy)"},
      {"Owner", "[appositum#7545](https://github.com/appositum)"},
      {"Guilds", "#{length(guilds)}"},
      {"Processes", "#{length :erlang.processes()}"},
      {"Memory Usage", "#{div :erlang.memory(:total), 1_000_000} MB"}
    ]

    Enum.reduce infos, %Embed{}, fn {name, value}, embed ->
      Embed.field(embed, name, value, inline: true)
    end
    |> Embed.color(@yellow)
    |> Embed.title("Thonk")
    |> Embed.thumbnail("http://i.imgur.com/6YToyEF.png")
    |> Embed.url("https://github.com/appositum/thonk")
    |> Embed.footer(text: "Uptime: #{uptime()}")
    |> Embed.send()
  end

  defp uptime do
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
  defp admin_check(guild, user_id) do
    member = guild.members
    |> Enum.find(&(&1.user.id == user_id))

    roles = guild.roles
    |> Enum.filter(fn role -> role.id in member.roles end)
    |> Enum.map(fn role ->
      role.permissions
      |> Permissions.contains?(role, :administrator)
    end)

    true in roles
  end
end
