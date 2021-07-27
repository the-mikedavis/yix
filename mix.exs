defmodule Mix.Tasks.Compile.TreeSitterNif do
  require Logger

  def run(_args) do
    {stdout, exit_code} =
      System.cmd("make", ["priv/tree_sitter_nif.so"], stderr_to_stdout: true)

    if exit_code == 0 do
      :ok
    else
      Logger.error("""
      'make priv/tree_sitter_nif.so' failed with exit code #{exit_code}:
      #{stdout}
      """)
    end
  end
end

defmodule Yix.MixProject do
  use Mix.Project

  def project do
    [
      app: :yix,
      compilers: [:tree_sitter_nif | Mix.compilers()],
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
