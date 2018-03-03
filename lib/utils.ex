defmodule Thonk.Utils do
  use Alchemy.Cogs
  alias Alchemy.Client
  require Alchemy.Embed, as: Embed

  @yellow 0xfac84b

  Cogs.def help do
    commands = Cogs.all_commands()
    |> Map.keys()
    |> Enum.join("\n")

    %Embed{color: @yellow, title: "All available commands", description: commands}
    |> Embed.send()
  end

  Cogs.def info do
    {:ok, app_version} = :application.get_key(:thonk, :vsn)
    {:ok, lib_version} = :application.get_key(:alchemy, :vsn)
    {:ok, guilds} = Client.get_current_guilds()
    guilds = length(guilds)

    memory = div :erlang.memory(:total), 1_000_000
    processes = length :erlang.processes()

    infos = [
      {"Prefix", Application.get_env(:thonk, :prefix)},
      {"Version", "#{app_version}"},
      {"Elixir Version", System.version()},
      {"Library", "[Alchemy #{lib_version}](https://github.com/cronokirby/alchemy)"},
      {"Author", "[appositum#7545](https://github.com/appositum)"},
      {"Guilds", "#{guilds}"},
      {"Processes", "#{processes}"},
      {"Memory Usage", "#{memory} MB"}
    ]

    Enum.reduce(infos, %Embed{color: @yellow}, fn {name, value}, embed ->
      Embed.field(embed, name, value, inline: true)
    end)
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
end
