local cosco = require("cosco.module")

---@class Lua
local M = {}

M.parse = function()
  vim.b.was_extension_executed = true

  if vim.b.prev_line_last_char == "," then
    cosco.make_it_a_comma()
  else
    cosco.remove_comma_or_semi_colon()
  end
end

return M
