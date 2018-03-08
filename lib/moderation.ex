defmodule Thonk.Moderation do
  use Alchemy.Cogs
  alias Alchemy.{Client, User}
  alias Thonk.Utils
  require Alchemy.Embed, as: Embed

  @yellow 0xfac84b

  @doc """
  Set a new prefix for the bot (administrator permission is needed).
  """
  Cogs.def set_prefix(new_prefix) do
    {:ok, guild} = Cogs.guild()

    case Utils.check_admin(guild, message.author.id) do
      false ->
        Cogs.say("You are not an administrator!")
      true ->
        Cogs.set_prefix(new_prefix)
        Application.put_env(:thonk, :prefix, new_prefix)
        Cogs.say("New prefix: `#{new_prefix}`")
    end
  end

  @doc """
  Informatino about some user (work in progress).
  """
  Cogs.def userinfo do
    {:ok, guild_id} = Cogs.guild_id()
    {:ok, member} = Client.get_member(guild_id, message.author.id)
    {:ok, roles} = Client.get_roles(guild_id)

    roles = roles
    |> Enum.map(fn role -> {role.id, role.name} end)
    |> Enum.filter(fn {id, _role} -> id in member.roles end)
    |> Enum.map(fn {_id, role} -> role end)
    |> Enum.join(", ")

    avatar = member.user
    |> User.avatar_url()
    |> String.replace(".jpg", ".png")

    nickname =
      case member.nick do
        nil -> "None"
        nick -> nick
      end

    infos = [
      {"ID", member.user.id},
      {"Username", member.user.username},
      {"Nickname", nickname},
      {"Tag", member.user.discriminator}
    ]

    Enum.reduce(infos, %Embed{color: @yellow}, fn {name, value}, embed ->
      Embed.field(embed, name, value, inline: true)
    end)
    |> Embed.field("Roles [#{length(roles)}]", Enum.join(roles, ", "))
    |> Embed.field("Joined", member.joined_at)
    |> Embed.thumbnail(avatar)
    |> Embed.send()
  end

  @doc """
  Information about the bot.
  """
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

    Enum.reduce(infos, %Embed{color: @yellow, title: "Thonk"}, fn {name, value}, embed ->
      Embed.field(embed, name, value, inline: true)
    end)
    |> Embed.thumbnail("http://i.imgur.com/6YToyEF.png")
    |> Embed.url("https://github.com/appositum/thonk")
    |> Embed.footer(text: "Uptime: #{Utils.uptime()}")
    |> Embed.send()
  end
end
