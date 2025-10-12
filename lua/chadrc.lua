-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

local overrides = require("configs.overrides")
local statusline_custom = require("configs.statusline")

M.base46 = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "ayu_light" },

  hl_override = {
    -- CPU usage colors
    St_cpu = { fg = "green", bg = "statusline_bg" },
    St_cpu_medium = { fg = "yellow", bg = "statusline_bg" },
    St_cpu_high = { fg = "red", bg = "statusline_bg" },

    -- RAM usage colors
    St_ram = { fg = "blue", bg = "statusline_bg" },
    St_ram_medium = { fg = "yellow", bg = "statusline_bg" },
    St_ram_high = { fg = "red", bg = "statusline_bg" },
  },
}

-- M.plugins = "plugins"

M.ui = vim.tbl_deep_extend("force", overrides.ui or {}, {
  statusline = {
    theme = "default",
    separator_style = "default",
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "cpu", "ram", "diagnostics", "lsp", "cwd", "cursor" },
    modules = {
      cpu = function()
        return statusline_custom.cpu()
      end,
      ram = function()
        return statusline_custom.ram()
      end,
    },
  },
})

return M
