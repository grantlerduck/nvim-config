local merge_tb = vim.tbl_deep_extend

local configs = require "nvchad.configs.lspconfig"
local on_init = configs.on_init
local on_attach = configs.on_attach
local capabilities = configs.capabilities

-- Basic servers with standard configuration
local servers = {
  "cssls",
  "ts_ls",
  "gopls",
  "templ",
  "biome",
  "pylsp",
  "rust_analyzer",
  "terraformls",
  "kotlin_lsp",
}

-- Configure servers using new API
for _, lsp in ipairs(servers) do
  local opts = {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- Check for server-specific settings
  local exists, settings = pcall(require, "configs.lsp.server-settings." .. lsp)
  if exists then
    opts = merge_tb("force", settings, opts)
  end

  vim.lsp.config(lsp, opts)
end

-- HTML server with custom filetypes
vim.lsp.config("html", {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "templ" },
})

-- HTMX server
vim.lsp.config("htmx", {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "templ" },
})

-- Clangd with custom settings
local exists, clangd_settings = pcall(require, "configs.lsp.server-settings.clangd")
if exists then
  vim.lsp.config("clangd", merge_tb("force", clangd_settings, {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
  }))
else
  vim.lsp.config("clangd", {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Tailwind CSS with custom settings
vim.lsp.config("tailwindcss", {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "templ", "astro", "javascript", "typescript", "react" },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        templ = "html",
      },
    },
  },
})

-- ESLint with custom on_attach
vim.lsp.config("eslint", {
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
  capabilities = capabilities,
})

-- Enable all configured servers
vim.lsp.enable({
  "html",
  "cssls",
  "ts_ls",
  "clangd",
  "gopls",
  "templ",
  "biome",
  "pylsp",
  "rust_analyzer",
  "terraformls",
  "htmx",
  "tailwindcss",
  "eslint",
  "kotlin_lsp",
})

vim.filetype.add { extension = { templ = "templ" } }

local custom_format = function()
  if vim.bo.filetype == "templ" then
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local cmd = "templ fmt " .. vim.fn.shellescape(filename)

    vim.fn.jobstart(cmd, {
      on_exit = function()
        -- Reload the buffer only if it's still the current buffer
        if vim.api.nvim_get_current_buf() == bufnr then
          vim.cmd "e!"
        end
      end,
    })
  else
    vim.lsp.buf.format()
  end
end

vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" }, callback = custom_format })

local config = {
  virtual_text = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "single",
    source = "always",
  },
}

vim.diagnostic.config(config)
