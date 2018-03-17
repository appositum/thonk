defmodule ThonkTest do
  use ExUnit.Case
  alias Thonk.Utils
  doctest Thonk

  test "exceeded characters limit" do
    assert Utils.check_exceed("testing") == "testing"
    assert Stream.cycle(["a"])
    |> Enum.take(4000)
    |> Enum.join()
    |> Utils.check_exceed()
    |> String.starts_with?(":warning: The command output exceeded the characters limit! (`4000/2000`)")
  end

  test "random hex" do
    pattern = ~r/^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, "Ff00a3")
    assert Regex.match?(pattern, "FF00AZ") == false
  end
end
