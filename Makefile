MIX = mix
CFLAGS = -g -O3 -ansi -Wall -Wextra -Wno-unused-parameter

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

TREE_SITTER_PATH = ./tree-sitter
TREE_SITTER_LANGUAGE_PATH = ./tree-sitter-nix

CFLAGS += -I$(ERLANG_PATH)
CFLAGS += -I$(TREE_SITTER_PATH)/lib/include
CFLAGS += -fPIC

ifeq ($(shell uname),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

.PHONY: all tree_sitter_nif clean

all: tree_sitter_nif

tree_sitter_nif:
	$(MIX) compile

priv/tree_sitter_nif.so: c_src/tree_sitter_nif.c
	$(MAKE) -C $(TREE_SITTER_PATH) libtree-sitter.a
	$(CC) $(CFLAGS) -shared $(LDFLAGS) c_src/tree_sitter_nif.c $(TREE_SITTER_LANGUAGE_PATH)/src/parser.c $(TREE_SITTER_LANGUAGE_PATH)/src/scanner.c $(TREE_SITTER_PATH)/libtree-sitter.a -o $@

clean:
	$(MIX) clean
	$(MAKE) -C $(TREE_SITTER_PATH) clean
	$(RM) priv/tree_sitter_nif.so
