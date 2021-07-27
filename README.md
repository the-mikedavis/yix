# Yix

Yix (pronounced like _yikes_) is a programming language which is

- high level
- purely functional (and non-general)
- dynamically typed
- interpreted

The syntax of yix is very similar to that of
[nix](https://github.com/NixOS/nix), but yix adds a feature sorely missing
in nix: pattern matching.

## Why non-general?

Yix is a non-general programming language. General-purpose programming languages
allow non-reproducible side-effects such as I/O and networking. These are very
useful tools that allow a program to get work done, but they can also make
it difficult to reason about a program.

## Implementation notes

- The syntax tree is parsed with [tree-sitter](https://github.com/tree-sitter/tree-sitter)
    - Yix uses a NIF (Native Implemented Function) to interoperate with the tree-sitter C API
