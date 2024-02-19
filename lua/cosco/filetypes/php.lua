local cosco = require("cosco.module")

---@class PHP
local M = {}

M.parse = function()
  vim.b.was_extension_executed = true

  if string.match(vim.b.next_line, "];$") then
    cosco.remove_comma_or_semi_colon()
  elseif vim.b.prev_line_last_char == "," then
    if vim.b.next_line_first_char == ")" then
      cosco.remove_comma_or_semi_colon()
    end
    vim.b.was_extension_executed = false
  else
    vim.b.was_extension_executed = false
  end
end

return M
