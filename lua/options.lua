require "nvchad.options"

-- Handle jar:// URIs for navigating into library sources (kotlin-lsp decompiled code)
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "jar://*",
  callback = function(args)
    local uri = args.match
    -- jar:///path/to/file.jar!/path/inside/jar
    local jar_path, entry_path = uri:match "^jar:///(.-%.jar)!/(.*)"
    if not jar_path or not entry_path then
      return
    end

    local buf = args.buf
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true

    -- Extract the file from the JAR using unzip
    local result = vim.fn.systemlist({ "unzip", "-p", "/" .. jar_path, entry_path })
    if vim.v.shell_error == 0 and #result > 0 then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
      -- Set filetype based on extension
      local ext = entry_path:match "%.(%w+)$"
      if ext == "kt" then
        vim.bo[buf].filetype = "kotlin"
      elseif ext == "java" then
        vim.bo[buf].filetype = "java"
      end
    else
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "-- Failed to extract " .. entry_path .. " from " .. jar_path })
    end

    vim.bo[buf].modifiable = false
  end,
})
