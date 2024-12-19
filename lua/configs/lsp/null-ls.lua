local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins
-- TODO: migrate to none-ls
local sources = {

  b.diagnostics.typos,

  -- webdev stuff
  -- b.formatting.deno_fmt,
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css", "yaml", "json" } },
  b.diagnostics.eslint_d,
  b.formatting.eslint_d,
  b.diagnostics.semgrep, -- go, python and js/ts, java

  -- Lua
  b.formatting.stylua,

  -- Shell
  b.formatting.shfmt,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },

  -- cpp
  b.formatting.clang_format,
  b.diagnostics.cppcheck,

  -- rust
  b.formatting.dprint.with { "rust", "toml" },
  b.formatting.rustfmt,

  -- go
  b.formatting.gofumpt,
  b.formatting.goimports_reviser,
  b.formatting.golines,
  --b.diagnostics.golangci_lint, this thing runs amok on a regular basis

  -- proto
  b.diagnostics.buf,

  -- python
  b.diagnostics.ruff,
  b.formatting.black,

  -- java
  --b.formatting.google_java_format,
}

null_ls.setup {
  debug = true,
  sources = sources,
  timeout_ms = 500000,
}

local M = {}

-- Avoiding LSP formatting conflicts - instead of nvim lsp, only use null-ls for formatting
M.lsp_formatting = function(bufnr)
  vim.lsp.buf.format {
    filter = function(client)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  }
end

return M
