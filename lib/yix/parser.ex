defmodule Yix.Parser do
  @moduledoc false

  # A module which interfaces with the tree-sitter C code in `c_src/`

  # setup the NIF
  @on_load :__load_nif__

  def __load_nif__ do
    :ok =
      :yix
      |> :code.priv_dir()
      |> :filename.join('parser')
      |> :erlang.load_nif(0)
  end

  # public API
  def parse(source, include_meta? \\ true) do
    source
    |> nif_parse(include_meta?)
    |> ast()
  end

  # fallback API if the NIF fails to load
  @failed_to_load_nif_message "parser NIF could not be loaded"

  def nif_parse(_source, _include_meta?) do
    raise @failed_to_load_nif_message
  end

  # private API

  # translate the concrete syntax tree from tree-sitter into the yix abstract
  # syntax tree
  defp ast(concrete_syntax_tree)

  # skip the cst's root node
  defp ast({:source_expression, _meta, [expression]}) do
    ast(expression)
  end

  # remove the { and } from attrset nodes
  defp ast({:attrset, meta, [{:"{", _, _} | rest]}) do
    {:attrset,
     meta,
     # drop :"}" token
     rest |> Enum.drop(-1) |> Enum.map(&ast/1)}
  end

  # drop the := and :";" tokens in binds
  defp ast({:bind, meta, [lhs, {:=, _, _}, rhs, {:";", _, _}]}) do
    {:bind, meta, [ast(lhs), ast(rhs)]}
  end

  # translate binary operators to a simpler ast
  defp ast({:binary, meta, [lhs, {operator, _, _}, rhs]}) do
    {operator, meta, [ast(lhs), ast(rhs)]}
  end

  # perform a similar translation for unary operators
  defp ast({:unary, meta, [{operator, _, _}, argument]}) do
    {operator, meta, [ast(argument)]}
  end

  # parse basic data types
  defp ast({:integer, _meta, integer_string}), do: String.to_integer(integer_string)

  defp ast({:float, _meta, float_string}), do: String.to_float(float_string)

  defp ast({:identifier, _meta, "true"}), do: true
  defp ast({:identifier, _meta, "false"}), do: false
  defp ast({:identifier, _meta, "null"}), do: nil

  # rename :app to :apply (how do I do an ascii eye roll?)
  defp ast({:app, meta, [lhs, rhs]}) do
    {:apply, meta, [ast(lhs), ast(rhs)]}
  end

  # remove :":" character from function asts
  defp ast({:function, meta, [bindings, {:":", _, _}, body]}) do
    {:function, meta, [ast(bindings), ast(body)]}
  end

  # drop all parens: the constructed syntax tree is already unambiguous
  defp ast({:parenthesized, _, [{:"(", _, _}, expression, {:")", _, _}]}) do
    ast(expression)
  end

  defp ast({type, meta, children}) when is_list(children) do
    {type, meta, Enum.map(children, &ast/1)}
  end

  defp ast(ast), do: ast
end
