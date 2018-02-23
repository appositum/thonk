use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic

config :thonk,
  token: System.get_env("TOKEN") || "your token here",
  prefix: System.get_env("COMMAND_PREFIX") || "t$"

config :alchemy,
  ffmpeg_path: "/path/to/ffmpeg",
  youtube_dl_path: "/path/to/youtube-dl"
