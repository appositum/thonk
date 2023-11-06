defmodule Thonk do
  use Application
  alias Alchemy.{Client, Cogs}

  def start(_type, _args) do
    case Application.get_env(:thonk, :token) do
      token ->
        prefix = Application.fetch_env!(:thonk, :prefix)
        bootstrap(token, prefix)
      nil ->
        raise "TOKEN environment variable is not set"
    end
  end

  defp bootstrap(token, prefix) do
    run = Client.start(token)
    load_modules()
    Cogs.set_prefix(prefix)
    run
  end

  defp load_modules do
    use Thonk.Events
    use Thonk.Commands
  end
end
