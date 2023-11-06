# Thonk

### A Discord Bot

[![Erlang/OTP](https://img.shields.io/badge/Erlang/OTP-%E2%89%A520-c50096.svg)](http://erlang.org/doc/)
[![Elixir](https://img.shields.io/badge/elixir-%E2%89%A51.5-75397d.svg)](https://elixir-lang.org/)

```elixir
# config/config.exs

use Mix.Config

config :porcelain, driver: Porcelain.Driver.Basic
config :thonk,
  token: "your token here"

# Necessary to voice functionality
config :alchemy,
  ffmpeg_path: "/path/to/ffmpeg",
  youtube_dl_path: "/path/to/youtube-dl"
```

`mix deps.get && mix run --no-halt` <br>
or run it in interactive mode <br>
`mix deps.get && iex -S mix`

### Some credits and stuff
- [**ihavenonickname**](https://github.com/ihavenonickname/bot-telegram-comentarios-xvideos) - The [comment](https://github.com/eudescar/thonk/blob/master/lib/commands/comment.ex) command idea.
- [**cronokirby**](https://github.com/cronokirby/alchemy) - Alchemy library
