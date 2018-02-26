defmodule Thonk do
  use Application
  alias Alchemy.{Client, Cogs}

  @token Application.fetch_env!(:thonk, :token)
  @prefix Application.fetch_env!(:thonk, :prefix)

  def start(_type, _args) do
    case System.get_env("TOKEN") do
      nil -> raise "TOKEN environment variable is not set"
      _   -> bootstrap_start()
    end
  end

  defp bootstrap_start do
    run = Client.start(@token)
    load_modules()
    Cogs.set_prefix(@prefix)
    run
  end

  defp load_modules do
    use Thonk.Events
    use Thonk.Commands
  end
end
