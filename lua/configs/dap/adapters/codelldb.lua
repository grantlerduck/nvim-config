local M = {}

M.adapter = {
  type = "server",
  port = "${port}",
  name = "codelldb",
  executable = {
    command = os.getenv "HOME" .. "/.local/share/nvim/mason/bin/codelldb", -- I installed codelldb through mason.nvim
    args = { "--port", "${port}" },
  },
}

M.config = {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

return M
