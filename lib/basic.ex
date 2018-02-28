defmodule Thonk.Basic do
  use Alchemy.Cogs

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
        |> exceed_check()
        |> Cogs.say()
    end
  end

  defp exceed_check(input) do
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
end
