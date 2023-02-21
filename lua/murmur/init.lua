local A = require('murmur.utils.autocmd')
local M = {}
vim.api.nvim_create_augroup('murmur.lua', { clear = true })
---------------------------------------------------------------------------------------------------

local fn = vim.fn
local api = vim.api


local function matchdelete(clear_word)
  if clear_word then
    vim.w.cursor_word = nil
  end
  if vim.w.cursor_word_match_id then
    pcall(fn.matchdelete, vim.w.cursor_word_match_id)
    vim.w.cursor_word_match_id = nil
  end
end


local function matchstr(...)
  local ok, ret = pcall(fn.matchstr, ...)
  if ok then
    return ret
  end
  return ""
end


-------------------------------------------------------------------------------------------------------
function M.setup(opts)
  if not opts then opts = {} end

  M.config_cursor_rgb = opts.cursor_rgb or { guifg = 'NONE', guibg = '#393939' }
    if type(M.config_cursor_rgb) ~= 'table' then M.config_cursor_rgb = {} end
    if type(M.config_cursor_rgb.guifg) ~= 'string' then M.config_cursor_rgb.guifg = 'NONE' end
    if type(M.config_cursor_rgb.guibg) ~= 'string' then M.config_cursor_rgb.guibg = '#393939' end
  M.yank_blink = opts.yank_blink or { enabled = true, on_yank = nil }
    if type(M.yank_blink) ~= 'table' then M.yank_blink = {} end
    if type(M.yank_blink.enabled) ~= 'boolean' then M.yank_blink.enabled = true end
    if type(M.yank_blink.on_yank) ~= 'table' then
      M.yank_blink.on_yank = {
        higroup = 'murmur_yank_hl',
        timeout = 200,
        on_visual = true
      }
    end

  M.cursor_rgb_always_use_config = opts.cursor_rgb_always_use_config or false
  M.max_len = opts.max_len or 20
  M.min_len = opts.min_len or 3
  M.disable_on_lines = opts.disable_on_lines or 2000
  M.exclude_filetypes = opts.exclude_filetypes or {}
  M.callbacks = opts.callbacks or {}

  A.create_autocmds()
end


function M.matchadd(insert_mode)
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > M.disable_on_lines then return end
  if vim.tbl_contains(M.exclude_filetypes, vim.bo.filetype) then return end

  local column = api.nvim_win_get_cursor(0)[2] + 1 -- one-based indexing.
    if insert_mode then column = column - 1 end
  local line = api.nvim_get_current_line()

  -- get the cursor word.
  -- \k are chars that can be keywords.
  local left = matchstr(line:sub(1, column), [[\k*$]])
  local right = matchstr(line:sub(column), [[^\k*]]):sub(2)

  local cursor_word = left .. right

  -- exit when on the same cursor word.
  if cursor_word == vim.w.cursor_word then return end

  for _, cb in ipairs(M.callbacks) do
    if type(cb) == 'function' then
      cb()
    end
  end

  vim.w.cursor_word = cursor_word

  matchdelete()

  if #cursor_word < M.min_len or #cursor_word > M.max_len or cursor_word:find("[\192-\255]+") then
    return
  end

  cursor_word = fn.escape(cursor_word, [[~"\.^$[]*]])
  vim.w.cursor_word_match_id = fn.matchadd('murmur_cursor_rgb', [[\<]] .. cursor_word .. [[\>]], -1)
end

function M.matchdelete()
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > M.disable_on_lines then return end
  matchdelete(true)
end

return M
