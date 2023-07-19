.PHONY: test
test:
	nvim --headless '+lua require("plenary"); vim.cmd("PlenaryBustedFile test/highlight_spec.lua")'
