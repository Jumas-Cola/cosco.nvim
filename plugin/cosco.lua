-- File: plugin/cosco.lua

-- ===============================================
-- Examples on how to use it (also on the README):
-- ===============================================

-- autocmd FileType c,cpp,css,java,javascript,perl,php,jade nnoremap <silent> <Leader>; <Plug>(cosco-commaOrSemiColon)
-- autocmd FileType c,cpp,css,java,javascript,perl,php,jade inoremap <silent> <Leader>; <C-o><Plug>(cosco-commaOrSemiColon)
-- command! CommaOrSemiColon call cosco#commaOrSemiColon()

local cosco = require("cosco")

vim.api.nvim_create_user_command("CommaOrSemiColon", cosco.comma_or_semi_colon, {})
vim.api.nvim_create_user_command("AutoCommaOrSemiColon", function()
  if vim.g.auto_comma_or_semicolon >= 1 then
    cosco.comma_or_semi_colon()
  end
end, {})

if not vim.g.auto_comma_or_semicolon then
  vim.g.auto_comma_or_semicolon = 0
end

if not vim.g.auto_comma_or_semicolon_events then
  vim.g.auto_comma_or_semicolon_events = { "InsertLeave" }
end

for _, event in ipairs(vim.g.auto_comma_or_semicolon_events) do
  vim.cmd(string.format("autocmd %s * AutoCommaOrSemiColon", event))
end

function AutoCommaOrSemiColonToggle()
  if vim.g.auto_comma_or_semicolon >= 1 then
    vim.g.auto_comma_or_semicolon = 0
    print("AutoCommaOrSemiColon is OFF")
  else
    vim.g.auto_comma_or_semicolon = 1
    print("AutoCommaOrSemiColon is ON")
  end
end

function CommaOrSemiColon()
  if vim.g.auto_comma_or_semicolon >= 1 then
    cosco.comma_or_semi_colon()
  end
end
