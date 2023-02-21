local M = {}
---------------------------------------------------------------------------------------------------
local out_v = false
local just_yank = false


local function create_murmur_cursor_rgb()
  -- pre-yanking.
  vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      if
        vim.v.event.new_mode == 'n'
        and (vim.v.event.old_mode == 'v' or vim.v.event.old_mode == 'V' or vim.v.event.old_mode == '')
      then
        out_v = true
      end
    end
  })
  vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      just_yank = true
    end
  })
  -- main part.
  vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      if vim.fn.mode() ~= 'n' then return end
      if -- just yank and out of visual mode.
        just_yank and out_v
      then
        out_v = false
        just_yank = false
        return
      end
      require('murmur').matchadd()
    end
  })
  vim.api.nvim_create_autocmd({ 'CursorMovedI' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function () require('murmur').matchadd(true) end
  })
  vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      if vim.v.event.new_mode == 'v'
        or vim.v.event.new_mode == 'V'
        or vim.v.event.new_mode == ''
      then require('murmur').matchdelete() end
    end
  })
  vim.api.nvim_create_autocmd({ 'WinLeave' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function () require('murmur').matchdelete() end
  })
  -- try recreate `murmur_cursor_rgb` by config.
  vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      if not require('murmur').cursor_rgb_always_use_config then return end

      local str_template_hi_cmd = [[ hi murmur_cursor_rgb ]]
      local config_cursor_rgb = require('murmur').config_cursor_rgb

      if config_cursor_rgb.guifg then
        str_template_hi_cmd = str_template_hi_cmd
          .. string.format([[ guifg=%s ]], config_cursor_rgb.guifg)
      end
      if config_cursor_rgb.guibg then
        str_template_hi_cmd = str_template_hi_cmd
          .. string.format([[ guibg=%s ]], config_cursor_rgb.guibg)
      end

      vim.cmd(str_template_hi_cmd)
    end
  })
end


function M.create_autocmds()
  create_murmur_cursor_rgb()
end


return M
