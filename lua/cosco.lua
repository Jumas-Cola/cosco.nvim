-- main module file
local module = require("cosco.module")

---@class Config
---@field opt string Your config option
local config = {
    cosco_ignore_comment_lines = vim.g.cosco_ignore_comment_lines or 0,
    cosco_ignore_ft_pattern = vim.g.cosco_ignore_ft_pattern or {},
    cosco_filetype_whitelist = vim.g.cosco_filetype_whitelist or nil,
    cosco_filetype_blacklist = vim.g.cosco_filetype_blacklist or nil
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.comma_or_semi_colon =
    function() return module.comma_or_semi_colon(M.config) end

return M
