local null_ls = require "null-ls"

local b = null_ls.builtins
local sources = {

  b.diagnostics.codespell,
  require "none-ls.formatting.trim_newlines",
  require "none-ls.formatting.trim_whitespace",

  -- webdev stuff
  -- b.formatting.deno_fmt,
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css", "yaml" } },
  b.formatting.biome.with {
    filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "jsonc", "css", "graphql" },
  },
  b.diagnostics.semgrep, -- go, python and js/ts, java

  -- Lua
  b.formatting.stylua,

  -- Shell
  b.formatting.shfmt,

  -- cpp
  b.formatting.clang_format,
  b.diagnostics.cppcheck,

  -- rust
  require "none-ls.formatting.rustfmt",

  -- go
  b.formatting.gofumpt,
  b.formatting.goimports_reviser,
  b.formatting.golines,
  --b.diagnostics.golangci_lint, this thing runs amok on a regular basis

  -- proto
  b.diagnostics.buf,

  -- python
  require "none-ls.formatting.ruff",
  require "none-ls.diagnostics.ruff",
  b.formatting.black,

  -- hcl
  b.formatting.hclfmt,
  b.diagnostics.terragrunt_validate,

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
