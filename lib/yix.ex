defmodule Yix do
  defdelegate parse(source, include_meta? \\ true), to: Yix.Parser

  def builtins do
    %{
      "add" => fn x -> fn y -> x + y end end,
      "div" => fn x -> fn y -> div(x, y) end end
    }
  end

  defdelegate reduce(ast), to: Yix.Interpreter
end
