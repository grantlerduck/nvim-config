local null_ls = require "null-ls"
local h = require "null-ls.helpers"

local b = null_ls.builtins

-- ktfmt formatter for Kotlin (stdin-based)
local ktfmt = h.make_builtin {
  name = "ktfmt",
  method = null_ls.methods.FORMATTING,
  filetypes = { "kotlin" },
  generator_opts = {
    command = "ktfmt",
    args = { "--kotlinlang-style", "-" },
    to_stdin = true,
  },
  factory = h.formatter_factory,
}

-- detekt linter for Kotlin
local detekt = h.make_builtin {
  name = "detekt",
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "kotlin" },
  generator_opts = {
    command = "detekt",
    args = function(params)
      local args = { "--input", params.temp_path }
      -- Use project detekt config if available
      for _, name in ipairs { "detekt.yml", "detekt-config.yml", "config/detekt/detekt.yml" } do
        local config = vim.fn.findfile(name, ".;")
        if config ~= "" then
          vim.list_extend(args, { "--config", config })
          break
        end
      end
      return args
    end,
    to_temp_file = true,
    from_stderr = true,
    format = "line",
    check_exit_code = function(code)
      return code <= 2 -- detekt returns 2 when issues are found
    end,
    on_output = h.diagnostics.from_pattern(
      ":(%d+):(%d+): (.+)",
      { "row", "col", "message" },
      { severities = { h.diagnostics.severities.warning } }
    ),
  },
  factory = h.generator_factory,
}
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

  -- hcl
  b.diagnostics.tfsec,
  b.diagnostics.terraform_validate,
  b.formatting.terraform_fmt,
  -- java
  --b.formatting.google_java_format,

  -- kotlin
  ktfmt,
  detekt,
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
