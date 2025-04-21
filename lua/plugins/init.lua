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
          -- claude = {
          --   max_tokens = 512,
          --   model = "claude-3-5-haiku-20241022",
          --   system = require("minuet.config").default_system,
          --   few_shots = require("minuet.config").default_few_shots,
          --   stream = true,
          --   optional = {
          --     -- pass any additional parameters you want to send to claude request,
          --     -- e.g.
          --     -- stop_sequences = nil,
          --   },
          -- },
          gemini = {
            optional = {
              generationConfig = {
                maxOutputTokens = 256,
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
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        temperature = 0,
        max_tokens = 4096,
      },
      behaviour = {
        enable_claude_text_editor_tool_mode = true,
      },
      web_search_engine = {
        provider = "brave", -- tavily, serpapi, searchapi, google, kagi, brave, or searxng
        proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
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
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
    end,
    requires = { "mfussenegger/nvim-dap" },
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
        ensure_installed = { "python", "delve", "go-debug-adapter", "codelldb", "js-debug-adapter" },
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
  -- {
  -- "zbirenbaum/copilot.lua",
  --event = "InsertEnter",
  --config = function()
  --require("copilot").setup(require "configs.copilot")
  --end,
  --endabled = false,
  --},

  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },
  {
    "javiorfo/nvim-soil",
    -- Optional for puml syntax highlighting:
    dependencies = { "javiorfo/nvim-nyctophilia" },
    lazy = true,
    ft = "plantuml",
    opts = {
      -- If you want to change default configurations
      -- If you want to use Plant UML jar version instead of the install version
      puml_jar = "/opt/homebrew/bin/plantuml",
      -- If you want to customize the image showed when running this plugin
      image = {
        darkmode = false, -- Enable or disable darkmode
        format = "svg", -- Choose between png or svg
        -- This is a default implementation of using nsxiv to open the resultant image
        -- Edit the string to use your preferred app to open the image (as if it were a command line)
        -- Some examples:
        -- return "feh " .. img
        -- return "xdg-open " .. img
        execute_to_open = function(img)
          return "open " .. img
        end,
      },
    },
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
      require("lspconfig").jdtls.setup {
        on_attach = require("nvchad.configs.lspconfig").on_attach,
        capabilities = require("nvchad.configs.lspconfig").capabilities,
        filetypes = { "java" },
      }
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
      { "rouge8/neotest-rust", version = "*" },
      { "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-golang", -- Registration
          require "neotest-rust",
        },
      }
    end,
  },
  { "nvzone/volt", lazy = true },
  { "nvzone/menu", lazy = true },
  -- visualize rust lifetimes
  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },
  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
}
return plugins
