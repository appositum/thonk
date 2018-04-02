defmodule ThonkTest do
  use ExUnit.Case
  alias Thonk.Utils
  doctest Thonk

  test "exceeded characters limit hastebin" do
    assert Utils.message_exceed("testing") == "testing"
    assert Stream.cycle(["a"])
    |> Enum.take(4000)
    |> Enum.join()
    |> Utils.message_exceed()
    |> String.starts_with?(":warning: **The command output exceeded the characters limit! (`4000/2000`)")
  end

  test "exceeded characters limit boolean" do
    assert Utils.message_exceed?("test") == false
    assert Stream.cycle(["a"])
    |> Enum.take(4000)
    |> Enum.join()
    |> Utils.message_exceed?()
  end

  test "random hex" do
    pattern = ~r/^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, Utils.color_random())
    assert Regex.match?(pattern, "Ff00a3")
    assert Regex.match?(pattern, "FF20Fg") == false
    assert Regex.match?(pattern, "FF00AZ") == false
    assert Regex.match?(pattern, "#FF00AZ") == false
    assert Regex.match?(pattern, "#E80000")
  end
end
