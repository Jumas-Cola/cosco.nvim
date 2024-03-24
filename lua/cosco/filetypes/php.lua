local cosco = require("cosco.module")

---@class PHP
local M = {}

M.parse = function()
  vim.b.was_extension_executed = true

  if string.match(vim.b.next_line, "^%s*];$") then
    cosco.remove_comma_or_semi_colon()
  elseif vim.b.prev_line_last_char == "," then
    if vim.b.next_line_first_char == ")" then
      cosco.remove_comma_or_semi_colon()
    elseif vim.b.next_line_first_char ~= "]" then
      cosco.make_it_a_comma()
    end
  else
    vim.b.was_extension_executed = false
  end
end

return M
