murmur.lua
===

## Intro.


Now you can do some murmur-ing(i.e. callbacks) when your cursor moving to a new wording. And yes, **super-fast** cursor word highlighting is included.


## Feat. and Demo.

1. super fast cursor word highlighting. (See [#Comparison](https://github.com/nyngwang/murmur.lua#comparison))

https://user-images.githubusercontent.com/24765272/204879903-44a0ee4e-6fad-4320-9a03-aa0c909eac11.mov

2. dynamic changing cursor word with `vim.g.cursor_rgb`.

https://user-images.githubusercontent.com/24765272/204715181-40acaf2f-196e-4eb4-8d43-bb6868c6695e.mov

3. IDE-like no blinking diagnostic message.

https://user-images.githubusercontent.com/24765272/204716620-b26909cc-9ba9-4475-9d2a-ab5619ab4ad5.mov


## Example Setup.

```lua
FOO = 'your_augroup_name'
vim.api.nvim_create_augroup(FOO, { clear = true })

use {
  -- Highlight cursor-word like an IDE.
  'nyngwang/murmur.lua',
  config = function ()
    require('murmur').setup {
      -- cursor_rgb = 'purple', -- default to '#393939'
      max_len = 80, -- maximum word-length to highlight
      -- disable_on_lines = 2000, -- to prevent lagging on large files. Default to 2000 lines.
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

## Reference

Extended from the original project: [`xiyaowong / nvim-cursorword`](https://github.com/xiyaowong/nvim-cursorword)

## Comparison

https://user-images.githubusercontent.com/24765272/204876866-b0dce9b9-d2da-4582-acb6-d0fe0344ecfe.mov
