local M = {}

M.adapter = {
  type = "executable",
  command = os.getenv "HOME" .. "/.local/share/nvim/mason/bin/kotlin-debug-adapter",
}

M.config = {
  {
    type = "kotlin",
    request = "launch",
    name = "Launch Kotlin Program",
    projectRoot = "${workspaceFolder}",
    mainClass = function()
      return vim.fn.input("Main class (e.g. com.example.MainKt): ")
    end,
  },
  {
    type = "kotlin",
    request = "attach",
    name = "Attach to Kotlin Process",
    hostName = "localhost",
    port = function()
      return tonumber(vim.fn.input("Port: ", "5005"))
    end,
    timeout = 10000,
    projectRoot = function()
      return vim.fs.root(vim.fn.expand "%:p", { "settings.gradle", "settings.gradle.kts" }) or vim.fn.getcwd()
    end,
  },
}

return M
