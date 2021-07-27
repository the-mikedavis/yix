#include "erl_nif.h"
#include <string.h>
#include <stdbool.h>
#include <tree_sitter/api.h>

TSLanguage *tree_sitter_nix();

static ERL_NIF_TERM
to_erl(ErlNifEnv *env, const char *source_code, TSNode node, bool include_meta)
{
  ERL_NIF_TERM children_term, meta_term;
  TSPoint start = ts_node_start_point(node);
  TSPoint end = ts_node_end_point(node);
  uint32_t child_count = ts_node_child_count(node);

  /* printf("Syntax tree with %d children: %s\n\n", child_count, ts_node_string(node)); */

  if (child_count == 0) {
    uint32_t start_byte = ts_node_start_byte(node);
    uint32_t size = ts_node_end_byte(node) - start_byte;
    char *token = (char *) enif_make_new_binary(env, size, &children_term);

    memcpy(token, source_code + start_byte, size);
  } else {
    ERL_NIF_TERM children[child_count];
    uint32_t i;

    for (i = 0; i < child_count; i++) {
      children[i] = to_erl(env, source_code, ts_node_child(node, i), include_meta);
    }

    children_term = enif_make_list_from_array(env, children, child_count);
  }

  if (include_meta) {
    meta_term = enif_make_list(env, 4,
      enif_make_tuple(env, 2,
        enif_make_atom(env, "start_row"),
        enif_make_int(env, start.row)
      ),
      enif_make_tuple(env, 2,
        enif_make_atom(env, "start_column"),
        enif_make_int(env, start.column)
      ),
      enif_make_tuple(env, 2,
        enif_make_atom(env, "end_row"),
        enif_make_int(env, end.row)
      ),
      enif_make_tuple(env, 2,
        enif_make_atom(env, "end_column"),
        enif_make_int(env, end.column)
      )
    );
  } else {
    meta_term = enif_make_list(env, 0);
  }

  /*
   * {node_type, meta_kwlist, children_or_value}
   */
  return enif_make_tuple(env, 3,
    enif_make_atom(env, ts_node_type(node)),
    meta_term,
    children_term
  );
}

static ERL_NIF_TERM
parse(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ErlNifBinary input;
  ERL_NIF_TERM output;
  char *source_code;
  char *include_meta_str;
  bool include_meta;
  TSParser *parser;
  TSTree *tree;
  TSNode root;

  if (enif_inspect_binary(env, argv[0], &input) == false) {
    return enif_make_badarg(env);
  }

  include_meta_str = (char *) malloc(6);
  if (enif_get_atom(env, argv[1], include_meta_str, 6, ERL_NIF_LATIN1) == false) {
    return enif_make_badarg(env);
  }

  include_meta = strncmp(include_meta_str, "true", 4) == 0 ? true : false;

  source_code = (char *) malloc((size_t) input.size + 1);
  memcpy(source_code, input.data, input.size);
  source_code[input.size] = 0;

  parser = ts_parser_new();

  ts_parser_set_language(parser, tree_sitter_nix());

  tree = ts_parser_parse_string(
    parser,
    NULL,
    source_code,
    strlen(source_code)
  );

  root = ts_tree_root_node(tree);


  output = to_erl(env, source_code, root, include_meta);

  ts_tree_delete(tree);
  ts_parser_delete(parser);

  return output;
}

static ErlNifFunc nif_funcs[] = {
  {"parse", 2, parse}
};

ERL_NIF_INIT(Elixir.Yix.Parser, nif_funcs, NULL, NULL, NULL, NULL)
