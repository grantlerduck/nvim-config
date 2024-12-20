local M = {}

M.treesitter = {
  ensure_installed = {
    "yaml",
    "toml",
    "json",
    "csv",
    "vim",
    "lua",
    "html",
    "css",
    "typescript",
    "c",
    "cpp",
    "python",
    "rust",
    "toml",
    "go",
    "gomod",
    "gosum",
    "gotmpl",
    "hcl",
  },
}

M.mason = {
  pkgs = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "biome",

    -- C / C++
    "clangd",
    "clang-format",
    "cmake-language-server",
    "cpplint",
    "cpptools",

    -- rust
    "rust_analyzer",

    -- shell
    "shellcheck",
    "shellharden",
    "bash-language-server",
    "bash-debug-adapter",
    "awk-language-server",

    -- python
    "black",
    "ruff",
    "pylsp",

    -- go
    "delve",
    "go-debug-adapter",
    "gofumpt",
    "goimports",
    "goimports-reviser",
    "golangci-lint",
    "golangci-lint-langserver",
    "golines",
    "gomodifytags",
    "gopls",
    "templ",
    "htmx-lsp",
    "tailwindcss-language-server",
    "gotestsum",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

M.gitsigns = {
  signs = {
    add = { text = "+" },
    change = { text = "▎" },
    delete = { text = "-" },
    topdelete = { text = "-" },
    changedelete = { text = "~" },
  },
}

M.ui = {
  tabufline = {
    lazyload = false,
  },
}

M.telescope = {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    },
    mappings = {
      i = {
        ["<esc>"] = function(...)
          require("telescope.actions").close(...)
        end,
      },
    },
  },
}

return M
