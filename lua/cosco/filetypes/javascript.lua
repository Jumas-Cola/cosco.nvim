local cosco = require("cosco.module")

---@class JavaScript
local M = {}

M.parse = function()
  vim.b.was_extension_executed = true

  if vim.b.current_line_last_char == "}" then
    if vim.b.next_line_last_char == "," then
      cosco.make_it_a_comma()
    end
  else
    vim.b.was_extension_executed = false
  end
end

return M
