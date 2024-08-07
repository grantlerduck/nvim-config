local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  -- b.formatting.deno_fmt,
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css", "yaml", "json" } },
  b.diagnostics.eslint_d,
  b.formatting.eslint_d,
  --b.formatting.eslint,
  --b.code_actions.eslint_d,

  -- Lua
  b.formatting.stylua,

  -- Shell
  b.formatting.shfmt,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },

  -- cpp
  b.formatting.clang_format,
  b.formatting.rustfmt,
  b.diagnostics.cppcheck,

  -- go
  b.formatting.gofumpt,
  b.formatting.goimports_reviser,
  b.formatting.golines,
  b.diagnostics.golangci_lint,

  -- python
  b.diagnostics.pylint,
  b.diagnostics.flake8,
  b.formatting.black,
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
