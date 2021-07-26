defmodule YixTest do
  use ExUnit.Case
  doctest Yix

  test "greets the world" do
    assert Yix.hello() == :world
  end
end
