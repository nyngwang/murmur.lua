murmur.lua
===

## Intro.


Cursorword highlighting with callbacks support(I call this *murmuring*). Created with performance in mind.


## DEMO

Dynamic coloring of your cursorword:

https://user-images.githubusercontent.com/24765272/210187287-14fb5b67-e8bd-4a40-a139-8b4b6f6d641f.mov

IDE-like no blinking diagnostic message with `cursor` scope.

https://user-images.githubusercontent.com/24765272/204716620-b26909cc-9ba9-4475-9d2a-ab5619ab4ad5.mov


## Example Setup.

Commented lines are the default.

```lua
local FOO = 'your_augroup_name'
vim.api.nvim_create_augroup(FOO, { clear = true })

use {
  'nyngwang/murmur.lua',
  config = function ()
    require('murmur').setup {
      -- cursor_rgb = {
      --  guibg = '#393939',
      -- },
      -- cursor_rgb_always_use_config = false, -- if set to `true`, then always use `cursor_rgb`.
      max_len = 80,
      min_len = 3, -- this is recommended since I prefer no cursorword highlighting on `if`.
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

    -- To create IDE-like no blinking diagnostic message with `cursor` scope. (should be paired with the callback above)
    vim.api.nvim_create_autocmd({ 'CursorHold' }, {
      group = FOO,
      pattern = '*',
      callback = function ()
        -- skip when a float-win already exists.
        if vim.w.diag_shown then return end

        -- open float-win when hovering on a cursor-word.
        if vim.w.cursor_word ~= '' then
          vim.diagnostic.open_float()
          vim.w.diag_shown = true
        end
      end
    })

    -- To create special cursorword coloring for the colortheme `typewriter-night`.
    -- remember to change it to the name of yours.
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
      group = FOO,
      pattern = 'typewriter-night',
      callback = function ()
        vim.cmd[[
          hi murmur_cursor_rgb guifg=#0a100d guibg=#ffee32
        ]]
      end
    })
  end
}
```

## Reference

Extended from the original project: [`xiyaowong / nvim-cursorword`](https://github.com/xiyaowong/nvim-cursorword)


## Comparison

https://user-images.githubusercontent.com/24765272/204876866-b0dce9b9-d2da-4582-acb6-d0fe0344ecfe.mov
