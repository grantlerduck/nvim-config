-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

-- local overrides = require("configs.overrides")

M.base46 = {
  theme = "nightowl",
  theme_toggle = { "pastelbeans", "nightowl" },
  -- hl_override = {
  -- 	Comment = { italic = true },
  -- 	["@comment"] = { italic = true },
  -- },
}

-- M.plugins = "plugins"

-- M.ui = overrides.ui

return M
