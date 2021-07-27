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

  # fallback API if the NIF fails to load
  @failed_to_load_nif_message "parser NIF could not be loaded"

  def parse(source, meta? \\ true)

  def parse(_source, _meta?) do
    raise @failed_to_load_nif_message
  end
end
