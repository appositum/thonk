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
           |> String.starts_with?(
             ":warning: **The command output exceeded the characters limit! (`4000/2000`)"
           )
  end

  test "exceeded characters limit boolean" do
    assert Utils.message_exceed?("test") == false

    assert Stream.cycle(["a"])
           |> Enum.take(4000)
           |> Enum.join()
           |> Utils.message_exceed?()
  end
end
