use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic
config :thonk,
  token: System.get_env("TOKEN"),
  prefix: System.get_env("COMMAND_PREFIX") || "t$"

config :alchemy,
  ffmpeg_path: "ffmpeg",
  youtube_dl_path: "youtube-dl"
