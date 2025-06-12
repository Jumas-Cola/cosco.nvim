local cosco = require("cosco.module")

---@class Octave
local M = {}

M.parse = function()
  vim.b.was_extension_executed = 1

  if vim.b.current_line_first_char == "%" then
    -- do nothing: it's a comment
  elseif string.match(cosco.strip(vim.b.current_line), "^function") then
    -- do nothing: it's a function declaration
  elseif cosco.strip(vim.b.current_line) == "end" then
    -- do nothing: it's an "end"
  elseif vim.b.current_line_last_char == ";" then
    -- toggle semicolon
    vim.api.nvim_exec2("s/;$//", {})
  else
    vim.api.nvim_exec2("s/$/;/", {})
  end
end

return M
