local M = {}
---------------------------------------------------------------------------------------------------
local just_yank = false

local function create_yank_blink()
	-- recreate `default_yank_hl`.
	vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			vim.api.nvim_set_hl(0, "murmur_yank_hl", { fg = "black", bg = "#f0e130" })
		end,
	})
	-- main part.
	vim.api.nvim_create_autocmd({ "TextYankPost" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			if not require("murmur").yank_blink.enabled then
				return
			end
			if type(require("murmur").yank_blink.on_yank) == "table" then
				pcall(vim.highlight.on_yank, require("murmur").yank_blink.on_yank)
				-- Ignore the possible `CursorMoved` after yanking and add the cursorword manually.
				just_yank = true
				vim.defer_fn(function()
					require("murmur").matchadd()
					just_yank = false
				end, 300)
			end
		end,
	})
end

local function create_murmur_cursor_rgb()
	-- main part.
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			if vim.fn.mode() ~= "n" then
				return
			end
			if -- move because of yank
				just_yank
			then
				return
			end
			require("murmur").matchadd()
		end,
	})
	vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			require("murmur").matchadd(true)
		end,
	})
	vim.api.nvim_create_autocmd({ "ModeChanged" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			if
				vim.v.event.new_mode == "v"
				or vim.v.event.new_mode == "V"
				or vim.v.event.new_mode == ""
				or (vim.v.event.new_mode == "no" or vim.v.event.old_mode == "no")
			then
				require("murmur").matchdelete()
				return
			end
			if vim.v.event.old_mode == "v" or vim.v.event.old_mode == "V" or vim.v.event.old_mode == "" then
				if just_yank then
					return
				end
				require("murmur").matchadd()
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "WinLeave" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			require("murmur").matchdelete()
		end,
	})
	-- try recreate `murmur_cursor_rgb` by config.
	vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
		group = "murmur.lua",
		pattern = "*",
		callback = function()
			if not require("murmur").cursor_rgb_always_use_config then
				return
			end
			local hl = require("murmur.utils.highlight")
			vim.defer_fn(function()
				hl.create_highlights()
			end, 150)
		end,
	})
end

function M.create_autocmds()
	create_murmur_cursor_rgb()
	create_yank_blink()
end

return M
