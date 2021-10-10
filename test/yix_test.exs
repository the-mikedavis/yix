defmodule YixSigil do
  def sigil_Y(content, _flags) do
    content |> Yix.parse |> Yix.reduce
  end
end

defmodule YixTest do
  use ExUnit.Case

  import YixSigil

  describe "basic usage of builtins" do
    test "builtins.add/2 adds two numbers" do
      assert ~Y"builtins.add 1 2" == 1 + 2
      assert ~Y"builtins.add 5 6" == 5 + 6
    end

    test "builtins.div/2 performs integer division" do
      assert ~Y"builtins.div 3 2" == div(3, 2)
      assert ~Y"builtins.div 3 2" == 1
    end
  end

  describe "basic syntax" do
    test "functions may be immediately applied to arguments" do
      assert ~Y"(x: y: x + y) 1 2" == 3
      assert ~Y"(x: y: x + y) 3 4" == 7
    end
  end
end
