require "nvchad.mappings"

local map = vim.keymap.set

-- General
map("n", ";", ":", { nowait = true, desc = "Command mode" })
map("n", "<Leader><Leader>", ":nohlsearch<CR>", { desc = "Clear search highlighting" })
map("n", "C-f", ":Format<CR>", { desc = "Format file" })
map("n", "<Leader>s", ":ClangdSwitchSourceHeader<CR>", { desc = "Switch between header and source file" })
map("n", "<Leader>tt", "<cmd>lua require'base46'.toggle_theme()<CR>", { desc = "Toggle theme" })

-- Telescope
map("n", "<C-p>", "<cmd>Telescope git_files<CR>", { desc = "Find files in version control" })
map("n", "<Leader>pf", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map(
  "n",
  "<Leader>pfa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "Find all files" }
)
map("n", "<Leader>pk", "<cmd>Telescope keymaps<CR>", { desc = "Show keymaps" })

-- Nvim DAP
map("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
map("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
map("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
map("n", "<Leader>dc<space>", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
map("n", "<Leader>d<space>", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
map(
  "n",
  "<Leader>dd",
  "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { desc = "Debugger set conditional breakpoint" }
)
map("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger terminate" })
map("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })
map("n", "<Leader>dus", function()
  local widgets = require "dap.ui.widgets"
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, { desc = "Open debugging sidebar" })
-- dap-go
map("n", "<Leader>gdt", "<cmd>lua require'dap-go'.debug_test()<CR>", { desc = "Debug go test" })
map("n", "<Leader>gdl", "<cmd>lua require'dap-go'.debug_last()<CR>", { desc = "Debug last go test" })

-- neotest
map("n", "<Leader>rt", "<cmd>lua require'neotest'.run.run({strategy = 'dap'})<CR>", { desc = "Run nearest test" })
map("n", "<Leader>tso", "<cmd>lua require'neotest'.summary.toggle()<CR>", { desc = "Toggle test summary" })
map("n", "<Leader>rat", "<cmd>lua require'neotest'.run.run({suite=true})<CR>", { desc = "Run all tests" })

-- gopher
map("n", "<Leader>gsj", "<cmd>GoTagAdd json<CR>", { desc = "Add json struct tags" })
map("n", "<Leader>gsy", "<cmd>GoTagAdd yaml<CR>", { desc = "Add yaml struct tags" })

-- Terminal
map({ "n", "t" }, "<C-\\>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal Toggle Floating term" })

-- File tree
map("n", "<C-a>", "<cmd>NvimTreeToggle<Cr>", { desc = "Toggle file tree" })

-- LSP config
map(
  "n",
  "<Leader>gl",
  "<cmd>lua vim.diagnostic.open_float(0, { scope = 'line', border = 'single' })<CR>",
  { desc = "Lsp show diagnostic" }
)
map("n", "<Leader>dF", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "Go to previous diagnostic" })
map("n", "<Leader>df", "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "Go to next diagnostic" })
map("n", "<Leader>dt", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope diagnostics" })
map("n", "<Leader>da", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Lsp code action" })

-- Null-ls
map(
  "n",
  "<C-f>",
  "<cmd>lua require('configs.lsp.null-ls').lsp_formatting(vim.api.nvim_get_current_buf())<CR>",
  { desc = "Format current file using null-ls" }
)

-- Buffer delete
map("n", "<Leader>q", "<cmd>BufDel<CR>", { desc = "Close buffer" })
map("n", "<Leader>Q", "<cmd>BufDel!<CR>", { desc = "Close buffer ignore changes" })

-- Buffer line
map("n", "<TAB>", "<C-i>") -- Keep <C-i> for jump forward
map("n", "L", function()
  require("nvchad.tabufline").next()
end, { desc = "Go to next buffer" })
map("n", "H", function()
  require("nvchad.tabufline").prev()
end, { desc = "Go to previous buffer" })

map("n", "<Leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close current buffer" })

-- Plenary
map("n", "<Leader>t", "<Plug>PlenaryTestFile", { desc = "Run plenary test on file" })

map("n", "<RightMouse>", function()
  vim.cmd.exec '"normal! \\<RightMouse>"'

  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true })
end, {})

-- minuet
-- {
--     -- accept whole completion
--     require('minuet.virtualtext').action.accept,
--     -- accept by line
--     require('minuet.virtualtext').action.accept_line,
--     -- accept n lines (prompts for number)
--     require('minuet.virtualtext').action.accept_n_lines,
--     require('minuet.virtualtext').action.next,
--     require('minuet.virtualtext').action.prev,
--     require('minuet.virtualtext').action.dismiss,
--     -- whether the virtual text is visible in current buffer
--     require('minuet.virtualtext').action.is_visible,
-- }

map("i", "<C-l>", "<cmd>lua require'minuet.virtualtext'.action.accept()<CR>", { desc = "Minuet accept virtual text" })
map("i", "<C-j>", "<cmd>lua require'minuet.virtualtext'.action.next()<CR>", { desc = "Minuet next virtual text" })
map("i", "<C-k>", "<cmd>lua require'minuet.virtualtext'.action.prev()<CR>", { desc = "Minuet previous virtual text" })
map("i", "<C-h>", "<cmd>lua require'minuet.virtualtext'.action.dismiss()<CR>", { desc = "Minuet dismiss virtual text" })
map("n", "<Leader>mv", "<cmd>Minuet virtualtext toggle<CR>", { desc = "Minuet toggle virtual text visibility" })
