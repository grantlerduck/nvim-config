local dap = require "dap"

-- ui
require "configs.dap.ui"

-- debuggers
local codelldb = require "configs.dap.adapters.codelldb"

dap.adapters.codelldb = codelldb.adapter

dap.configurations.c = codelldb.config
dap.configurations.cpp = codelldb.config
dap.configurations.rust = codelldb.config

-- kotlin
local kotlin = require "configs.dap.adapters.kotlin"

dap.adapters.kotlin = kotlin.adapter
dap.configurations.kotlin = kotlin.config
