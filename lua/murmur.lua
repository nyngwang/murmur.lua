local M = {}

local fn = vim.fn
local api = vim.api
local cursor_rgb = '#393939'
local max_len = 20
local disable_on_lines = 2000
local exclude_filetypes = {}
local callbacks = {}
vim.api.nvim_create_augroup('murmur.lua', { clear = true })


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


local function setup_vim_autocmds()
  vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
    group = 'murmur.lua',
    pattern = '*',
    command = 'hi CURSOR_RGB gui=NONE guibg='..cursor_rgb,
  })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function () M.matchadd() end
  })
  vim.api.nvim_create_autocmd({ 'WinLeave' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function () M.matchdelete() end
  })
end


-------------------------------------------------------------------------------------------------------

function M.setup(opt)
  cursor_rgb = opt.cursor_rgb ~= nil and opt.cursor_rgb or cursor_rgb
  max_len = opt.max_len ~= nil and opt.max_len or max_len
  disable_on_lines = opt.disable_on_lines ~= nil and opt.disable_on_lines or disable_on_lines
  exclude_filetypes = opt.exclude_filetypes ~= nil and opt.exclude_filetypes or exclude_filetypes
  callbacks = opt.callbacks ~= nil and opt.callbacks or callbacks

  setup_vim_autocmds()
end

function M.matchadd()
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > disable_on_lines then return end
  if vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
    return
  end

  local column = api.nvim_win_get_cursor(0)[2] + 1 -- one-based indexing.
  local line = api.nvim_get_current_line()

  -- get the cursor word.
  -- \k are chars that can be keywords.
  local left = matchstr(line:sub(1, column), [[\k*$]])
  local right = matchstr(line:sub(column), [[^\k*]]):sub(2)

  local cursor_word = left .. right

  -- exit when on the same cursor word.
  if cursor_word == vim.w.cursor_word then
    return
  end

  for _, cb in ipairs(callbacks) do
    cb()
  end

  vim.w.cursor_word = cursor_word

  matchdelete()

  if #cursor_word < 3 or #cursor_word > max_len or cursor_word:find("[\192-\255]+") then
    return
  end

  cursor_word = fn.escape(cursor_word, [[~"\.^$[]*]])
  vim.w.cursor_word_match_id = fn.matchadd('CURSOR_RGB', [[\<]] .. cursor_word .. [[\>]], -1)
end

function M.matchdelete()
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > disable_on_lines then return end
  matchdelete(true)
end

return M
