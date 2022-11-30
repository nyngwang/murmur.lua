murmur.lua
===

## Demo.

TBU.


## Example Setup.

```lua
FOO = 'your_augroup_name'
vim.api.nvim_create_augroup(FOO, { clear = true })

use {
-- Highlight cursor-word like an IDE.
'nyngwang/murmur.lua',
config = function ()
  vim.g.cursor_rgb = '#393939'
  require('murmur').setup {
    max_len = 80, -- maximum word-length to highlight
    exclude_filetypes = {},
    callbacks = {
      -- to trigger the close_events of vim.diagnostic.open_float.
      function ()
        -- Close floating diag. and make it triggerable again.
        vim.cmd('doautocmd InsertEnter')
        vim.w.diag_shown = false
      end,
    }
  }
  vim.api.nvim_create_autocmd('CursorHold', {
    group = FOO,
    pattern = '*',
    callback = function ()
      -- skip when a float-win already exists.
      if vim.w.diag_shown then return end

      -- open float-win when hovering on a cursor-word.
      if vim.w.cursor_word ~= '' then
        vim.diagnostic.open_float(nil, {
          focusable = true,
          close_events = { 'InsertEnter' },
          border = 'rounded',
          source = 'always',
          prefix = ' ',
          scope = 'cursor',
        })
        vim.w.diag_shown = true
      end
    end
  })
end
}
```
