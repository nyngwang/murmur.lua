local M = {}
---------------------------------------------------------------------------------------------------
local just_yank = false


local function create_yank_blink()
  -- recreate `default_yank_hl`.
  vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      vim.cmd [[
        hi murmur_yank_hl guifg=black guibg=#f0e130
      ]]
    end
  })
  -- main part.
  vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      if not require('murmur').yank_blink.enabled then return end
      if type(require('murmur').yank_blink.on_yank) == 'table' then
        pcall(vim.highlight.on_yank, require('murmur').yank_blink.on_yank)
        -- Ignore the possible `CursorMoved` after yanking and add the cursorword manually.
        just_yank = true
        vim.defer_fn(function ()
          require('murmur').matchadd()
          just_yank = false
        end, 300)
      end
    end,
  })
end


local function create_murmur_cursor_rgb()
  -- main part.
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorHold' }, {
    group = 'murmur.lua',
    pattern = '*',
    callback = function ()
      if vim.fn.mode() ~= 'n' then return end
      if -- move because of yank
        just_yank
      then return end
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
        or (vim.v.event.new_mode == 'no' or vim.v.event.old_mode == 'no')
      then
        require('murmur').matchdelete()
        return
      end
      if
        vim.v.event.old_mode == 'v'
        or vim.v.event.old_mode == 'V'
        or vim.v.event.old_mode == ''
      then
        if just_yank then return end
        require('murmur').matchadd()
      end
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
  create_yank_blink()
end


return M
