# cosco.nvim

Comma and semi-colon insertion bliss for vim.

Unofficial Lua translation of plugin:

[lfilho/cosco.vim](https://github.com/lfilho/cosco.vim)

Provides command 'CommaOrSemiColon', example usage:

```lua
local map = vim.api.nvim_set_keymap

-- Cosco
map("n", "<Leader>;", "<Cmd>CommaOrSemiColon<CR>", {
    noremap = true,
    silent = true,
    desc = "Auto comma or semicolon"
})
```
