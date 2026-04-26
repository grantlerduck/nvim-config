local overrides = require "configs.overrides"
local plugins = {
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  { "folke/neodev.nvim", opts = {} },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    lazy = false, -- somehow does not load otherwise
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cL",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    modes = {
      preview_float = {
        mode = "diagnostics",
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
    },
  },
  {
    "dense-analysis/ale",
    dependencies = { "bufbuild/vim-buf" },
    config = function()
      local g = vim.g
      g.ale_linters = {
        lua = { "lua_language_server" },
        proto = { "buf-lint" },
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = function()
      require("neodev").setup { library = { plugins = { "nvim-dap-ui" }, types = true } }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "nvimtools/none-ls.nvim",
        dependencies = {
          "nvimtools/none-ls-extras.nvim",
        },
        config = function()
          require "configs.lsp.null-ls"
        end,
      },
    },
    config = function()
      require("nvchad.configs.lspconfig").defaults() -- nvchad defaults for lua
      require "configs.lsp"
    end, -- Override to setup mason-lspconfig
  },
  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = overrides.treesitter,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = overrides.telescope,
  },
  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      lazy = false,
      config = function()
        require("telescope").load_extension "fzf"
      end,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = overrides.gitsigns,
  },
  { -- I want to use mineut as my secondary AI assistenace with a cheaper and faster model whiel Avantes chat is my main AI tool
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup {
        virtualtext = {
          auto_trigger_ft = { "*" },
        },
        provider = "gemini",
        cmp = {
          enable_auto_complete = false,
        }, -- i prefer to manually invoke it
        add_single_line_entry = false,
        provider_options = {
          gemini = {
            model = "gemini-3.1-flash-lite-preview",
            optional = {
              generationConfig = {
                maxOutputTokens = 512,
              },
              safetySettings = {
                {
                  -- HARM_CATEGORY_HATE_SPEECH,
                  -- HARM_CATEGORY_HARASSMENT
                  -- HARM_CATEGORY_SEXUALLY_EXPLICIT
                  category = "HARM_CATEGORY_DANGEROUS_CONTENT",
                  -- BLOCK_NONE
                  threshold = "BLOCK_ONLY_HIGH",
                },
              },
            },
          },
        },
      }
    end,
  },
  { "nvim-lua/plenary.nvim" },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- if you wish to use autocomplete
      table.insert(opts.sources, 1, {
        name = "minuet",
        group_index = 1,
        priority = 100,
      })

      table.insert(opts.sources, 2, {
        name = "crates",
        group_index = 2,
        priority = 10,
      })

      opts.performance = {
        -- It is recommended to increase the timeout duration due to
        -- the typically slower response speed of LLMs compared to
        -- other completion sources. This is not needed when you only
        -- need manual completion.
        fetching_timeout = 3000,
      }

      opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
        -- if you wish to use manual complete
        ["<A-y>"] = require("minuet").make_cmp_map(), -- option/alt + y
        -- You don't need to worry about <CR> delay because lazyvim handles this situation for you.
        ["<CR>"] = nil,
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    },
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      require "configs.dap"
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
    requires = { "mfussenegger/nvim-dap" },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup {
        ensure_installed = {
          "python",
          "delve",
          "go-debug-adapter",
          "codelldb",
          "js-debug-adapter",
          "kotlin-debug-adapter",
        },
      }
    end,
  },

  -- better bdelete, close buffers without closing windows
  {
    "ojroques/nvim-bufdel",
    lazy = false,
  },
  {
    "vimwiki/vimwiki",
  },
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      -- your config goes here
      -- or just leave it empty :)
    },
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },
  {
    "maxandron/goplements.nvim",
    ft = "go",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  --[[{
    "nvim-java/nvim-java",
    lazy = false,
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "nvim-java/nvim-java-dap",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      {
        "williamboman/mason.nvim",
        opts = {
          registries = {
            "github:nvim-java/mason-registry",
            "github:mason-org/mason-registry",
          },
        },
      },
    },
    config = function()
      require("java").setup {}
      -- Using new LSP API instead of lspconfig
      vim.lsp.config("jdtls", {
        on_attach = require("nvchad.configs.lspconfig").on_attach,
        capabilities = require("nvchad.configs.lspconfig").capabilities,
        filetypes = { "java" },
      })
      vim.lsp.enable("jdtls")
    end,
  },]]
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    config = true,
  },
  {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    completion = {
      cmp = {
        enabled = true,
      },
      crates = {
        enabled = true,
        max_results = 5,
        min_chars = 3,
      },
    },
    null_ls = {
      enabled = true,
      name = "crates.nvim",
    },
    config = function()
      require("crates").setup()
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "weilbith/neotest-gradle", -- Gradle adapter
      { "rouge8/neotest-rust", version = "*" },
      { "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
    },
    config = function()
      -- Patch neotest-gradle for multi-module project support
      local gradle = require "neotest-gradle"
      local sep = package.config:sub(1, 1)

      local original_build_spec = gradle.build_spec
      gradle.build_spec = function(args)
        local position = args.tree:data()
        local module_dir = vim.fs.root(position.path, { "build.gradle", "build.gradle.kts" })
        local root_dir = vim.fs.root(position.path, { "settings.gradle", "settings.gradle.kts" })

        if not root_dir or not module_dir or root_dir == module_dir then
          return original_build_spec(args)
        end

        local gradlew = root_dir .. sep .. "gradlew"
        if vim.fn.executable(gradlew) ~= 1 then
          gradlew = "gradle"
        end

        local rel_path = module_dir:sub(#root_dir + 2)
        local gradle_module = ":" .. rel_path:gsub(sep, ":")

        local filter = {}
        if position.type == "test" or position.type == "namespace" then
          vim.list_extend(filter, { "--tests", "'" .. position.id .. "'" })
        elseif position.type == "file" then
          for _, pos in args.tree:iter() do
            if pos.type == "namespace" then
              vim.list_extend(filter, { "--tests", "'" .. pos.id .. "'" })
            end
          end
        end

        local command = { gradlew, "--project-dir", root_dir, gradle_module .. ":test" }
        vim.list_extend(command, filter)

        return {
          command = table.concat(command, " "),
          context = {
            test_resuls_directory = module_dir .. sep .. "build" .. sep .. "test-results" .. sep .. "test",
          },
        }
      end

      require("neotest").setup {
        adapters = {
          require "neotest-golang", -- Registration
          require "neotest-rust",
          gradle,
        },
      }
    end,
  },
  { "nvzone/volt", lazy = true },
  { "nvzone/menu", lazy = true },
  -- visualize rust lifetimes
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },
  {
    "mg979/vim-visual-multi",
    keys = { "<C-d>", "<C-S-j>", "<C-S-k>" },
  },
}
return plugins
