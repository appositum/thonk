defmodule ThonkTest do
  use ExUnit.Case
  doctest Thonk

  test "greets the world" do
    assert Thonk.hello() == :world
  end
end
