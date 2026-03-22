-- Debug helper for multi-module Gradle projects.
-- The adapter patching is done in plugins/init.lua.
local M = {}
local sep = package.config:sub(1, 1)

--- Debug the nearest Kotlin/Gradle test.
--- Runs the test with --debug-jvm, polls for port 5005, then auto-attaches DAP.
M.debug_nearest_test = function()
  local file_path = vim.fn.expand "%:p"
  local module_dir = vim.fs.root(file_path, { "build.gradle", "build.gradle.kts" })
  local root_dir = vim.fs.root(file_path, { "settings.gradle", "settings.gradle.kts" })

  if not root_dir or not module_dir then
    vim.notify("Could not determine Gradle project root", vim.log.levels.ERROR)
    return
  end

  local gradlew = root_dir .. sep .. "gradlew"
  if vim.fn.executable(gradlew) ~= 1 then
    gradlew = "gradle"
  end

  local rel_path = module_dir:sub(#root_dir + 2)
  local gradle_module = ":" .. rel_path:gsub(sep, ":")

  local test_filter = ""
  local rel_to_module = file_path:sub(#module_dir + 2)
  local class_path = rel_to_module:match "src/test/kotlin/(.+)%.kt$"
  if class_path then
    local class_name = class_path:gsub("/", ".")
    test_filter = " --tests '" .. class_name .. "'"
  end

  local cmd = gradlew .. " --project-dir " .. root_dir .. " " .. gradle_module .. ":test" .. test_filter .. " --debug-jvm"

  vim.notify("Starting Gradle test with --debug-jvm, waiting for port 5005...", vim.log.levels.INFO)

  require("nvchad.term").toggle {
    pos = "sp",
    id = "gradleDebug",
    cmd = cmd,
  }

  -- Poll for port 5005 — Gradle needs time to compile before the JVM debug port opens
  local attempts = 0
  local timer = vim.uv.new_timer()
  timer:start(3000, 2000, vim.schedule_wrap(function()
    attempts = attempts + 1
    local ok = vim.fn.system "lsof -i :5005 2>/dev/null"
    if ok ~= "" and ok:find "LISTEN" then
      timer:stop()
      timer:close()
      vim.notify("JVM debug port ready, attaching DAP...", vim.log.levels.INFO)
      require("dap").run {
        type = "kotlin",
        request = "attach",
        name = "Attach to Gradle Test",
        hostName = "localhost",
        port = 5005,
        timeout = 10000,
        projectRoot = root_dir,
      }
    elseif attempts > 60 then -- 2 minutes timeout
      timer:stop()
      timer:close()
      vim.notify("Timed out waiting for JVM debug port 5005", vim.log.levels.ERROR)
    end
  end))
end

return M
