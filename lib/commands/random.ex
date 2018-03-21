defmodule Thonk.Commands.Random do
  @moduledoc false
  use Alchemy.Cogs
  alias Thonk.Utils
  require Alchemy.Embed, as: Embed

  Cogs.group("random")

  Cogs.def color do
    "#" <> Utils.color_random()
    |> Utils.color_embed()
    |> Embed.send("", file: "lib/assets/color.jpg")

    File.rm("lib/assets/color.jpg")
  end

  Cogs.def cat do
    image = HTTPoison.get!("http://aws.random.cat/meow").body
    |> Poison.decode!()
    |> Map.get("file")

    %Embed{image: image}
    |> Embed.send()
  end

  Cogs.def dog do
    image = HTTPoison.get!("https://random.dog/woof.json").body
    |> Poison.decode!()
    |> Map.get("url")

    %Embed{image: image}
    |> Embed.send()
  end
end
