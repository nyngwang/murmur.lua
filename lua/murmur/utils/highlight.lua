local M = {}

M.config = {}

local bit = require("bit")

---@param rgb number
---Converts an rgb number into a hex string
function M.hex(rgb)
	local r = bit.rshift(bit.band(rgb, 0xff0000), 16)
	local g = bit.rshift(bit.band(rgb, 0x00ff00), 8)
	local b = bit.band(rgb, 0x0000ff)

	return ("#%02x%02x%02x"):format(r, g, b)
end

---Alias to `vim.api.nvim_get_hl_id_by_name`
M.hl_id = vim.api.nvim_get_hl_id_by_name

---Alias to `vim.api.nvim_get_hl_by_id`
M.hl_by_id = vim.api.nvim_get_hl

local mapper

local map_fg = function(...)
	mapper.fg(...)
end

local map_bg = function(...)
	mapper.bg(...)
end

local map_sp = function(...)
	mapper.sp(...)
end

local function map_props(self, gui, prop)
	for _, g in ipairs({
		"bold",
		"italic",
		"underline",
		"undercurl",
		"underdouble",
		"underdotted",
		"underdashed",
		"strikethrough",
		"reverse",
		"nocombine",
	}) do
		if gui:find(g) then
			self[g] = true
		end
	end
	self[prop] = nil
end

local function map_color(prop)
	return function(self, v, k)
		if type(v) == "number" then
			v = M.hex(v)
		elseif v:sub(1, 1) ~= "#" and vim.fn.hlexists(v) == 1 then
			v = M.attr(v, prop)
		end
		self[k] = nil
		self[prop] = v
	end
end

mapper = {
	bold = true,
	underline = true,
	undercurl = true,
	underdouble = true,
	underdotted = true,
	underdashed = true,
	strikethrough = true,
	italic = true,
	reverse = true,
	nocombine = true,
	link = true,
	default = true,
	blend = true,
	ctermbg = map_bg,
	ctermfg = map_fg,
	foreground = map_fg,
	background = map_bg,
	special = map_sp,
	guifg = map_fg,
	guibg = map_bg,
	guisp = map_sp,
	fg = map_color("fg"),
	bg = map_color("bg"),
	sp = map_color("sp"),
	gui = map_props,
	style = map_props,
}

---@param hl table
function M.sanitize(hl)
	for _, k in ipairs(vim.tbl_keys(hl)) do
		local v = hl[k]
		if mapper[k] ~= nil then
			if type(mapper[k]) == "string" then
				hl[mapper[k]] = hl[k]
			elseif type(mapper[k]) == "function" then
				mapper[k](hl, v, k)
			end
		else
			hl[k] = nil
		end
	end
	return hl
end

---@param group string | integer
function M.get(group)
	return M.sanitize(M.hl_by_id(0, type(group) == "number" and { id = group } or { name = group }))
end

function M.attr(group, attr)
	return M.get(group)[attr]
end

function M.setup(all, current)
	if current then
		M.config.current = current
	elseif M.config.current and all == nil then
		current = M.config.current
	end
	if all then
		M.config.all = all
	elseif M.config.all then
		all = M.config.all
	end

	if type(all) == "table" then
		all = M.sanitize(all)
	elseif type(all) == "string" then
		if all:sub(1, 1) ~= "#" and vim.fn.hlexists(all) == 1 then
			all = M.get(all)
		end
	else
		all = { fg = "NONE", bg = "#393939" }
	end

	if type(current) == "table" then
		current = M.sanitize(current)
	elseif type(current) == "string" then
		if current:sub(1, 1) ~= "#" and vim.fn.hlexists(current) == 1 then
			current = M.get(current)
		end
	else
		current = all
	end
	M.all = all
	M.current = current
end

function M.create_highlights()
	if M.all then
		vim.api.nvim_set_hl(0, "murmur_cursor_rgb", M.all)
	end
	if M.current then
		vim.api.nvim_set_hl(0, "murmur_cursor_rgb_current", M.current)
	end
end

return M
