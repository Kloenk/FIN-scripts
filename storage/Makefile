
DEFAULT_SRC:=debug.lua lib.lua
ITEMROUTER_SRC:=$(DEFAULT_SRC) ItemRouter/panel.lua

FENNEL_ARGS ?=

%.lua: %.fnl macro.fnl lib.fnl network.fnl
	echo "package = { preload = {} }" > $@
	fennel $(FENNEL_ARGS) --globals "computer,event,component,findClass" -c $< >> $@

fmt: $(wildcard *.fnl)
	for file in $^; do \
		fnlfmt --fix $$file; \
	done
