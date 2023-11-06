use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic

config :thonk,
  token: "your token here"

config :alchemy,
  ffmpeg_path: "/usr/bin/ffmpeg",
  youtube_dl_path: "/usr/bin/youtube-dl"
