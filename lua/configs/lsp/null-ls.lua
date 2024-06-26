local present, null_ls = pcall(require, "null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

if not present then
	return
end

local b = null_ls.builtins

local sources = {

	-- webdev stuff
	b.formatting.deno_fmt,
	b.formatting.prettier.with({ filetypes = { "html", "markdown", "css" } }),

	-- Lua
	b.formatting.stylua,

	-- Shell
	b.formatting.shfmt,
	b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),

	-- cpp
	b.formatting.clang_format,
	b.formatting.rustfmt,
	b.diagnostics.cppcheck,

	-- go
	b.formatting.gofumpt,
	b.formatting.goimports_reviser,
	b.formatting.golines,
	b.diagnostics.golangci_lint,
}

null_ls.setup({
	debug = true,
	sources = sources,
})

local M = {}

-- Avoiding LSP formatting conflicts - instead of nvim lsp, only use null-ls for formatting
M.lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

M.on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end

return M
