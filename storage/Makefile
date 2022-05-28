
DEFAULT_SRC:=debug.lua lib.lua
ITEMROUTER_SRC:=$(DEFAULT_SRC) ItemRouter/panel.lua


%.lua: %.fnl macro.fnl lib.fnl
	echo "package = { preload = {} }" > $@
	fennel --globals _G -c $< >> $@

fmt: $(wildcard *.fnl)
	for file in $^; do \
		fnlfmt --fix $$file; \
	done
