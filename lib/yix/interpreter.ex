defmodule Yix.Interpreter do
  def reduce(expression, scope \\ %{"builtins" => Yix.builtins()})

  def reduce({:apply, _, [lhs, rhs]}, scope) do
    reduce(lhs, scope).(reduce(rhs, scope).())
  end

  def reduce({:select, _, [{:identifier, _, identifier}, {:., _, _}, path]}, scope) do
    get_in(scope, [identifier | reduce(path, scope)])
  end

  def reduce({:attrpath, _, identifiers}, _scope) do
    Enum.map(identifiers, fn {:attr_identifier, _, identifier} -> identifier end)
  end

  def reduce({:function, _, [{:identifier, _, identifier}, body]}, scope) do
    fn value ->
      reduce(body, Map.put(scope, identifier, value))
    end
  end

  def reduce({:+, _, [lhs, rhs]}, scope) do
    reduce(lhs, scope).() + reduce(rhs, scope).()
  end

  def reduce({:identifier, _, identifier}, scope) do
    # TODO better failure behaviour when the identifier does not exist in scope
    reduce(Map.fetch!(scope, identifier), scope)
  end

  def reduce(value, _scope) when is_number(value), do: fn -> value end
end
