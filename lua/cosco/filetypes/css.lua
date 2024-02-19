local cosco = require("cosco.module")

---@class CSS
local M = {}

M.parse = function()
  vim.b.was_extension_executed = true

  if vim.b.prev_line_last_char == "}" then
    cosco.make_it_a_comma()
  elseif vim.b.next_line_last_char == "}" then
    cosco.make_it_a_semi_colon()
  elseif vim.b.prev_line_last_char == "{" then
    cosco.make_it_a_semi_colon()
  elseif vim.b.prev_line_last_char == "," then
    cosco.make_it_a_comma()
  elseif vim.b.original_line_num == 1 then
    cosco.make_it_a_comma()
  elseif vim.b.current_line_first_char == "}" then
    cosco.make_it_a_semi_colon()
  else
    vim.b.was_extension_executed = false
  end
end

return M
