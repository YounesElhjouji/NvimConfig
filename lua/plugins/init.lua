return {
  {
    dir = "~/Projects/nvim-copy", -- Path to your local plugin
    lazy = false,
    config = function()
      require("nvim_copy").setup({
        ignore = { "node_modules/*", "*.log", "build/*", "*/configs/*", "*.toml", "*.md" }
      })
    end,
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require("configs.dashboard")
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  },
  {
    'echasnovski/mini.nvim',
    version = '*',
    lazy = false,
    config = function()
      require('mini.ai').setup()
    end
  },
  {
    'smoka7/hop.nvim',
    version = "*",
    opts = {
      keys = 'etovxqpdygfblzhckisuran'
    }
  },
  {
    "tpope/vim-surround",
    lazy = false,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    config = function()
      require("configs.noice")
    end,
    dependencies = {
      "hrsh7th/nvim-cmp",
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
  {
    "ThePrimeagen/harpoon",
    config = function()
      require("harpoon").setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 20,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  { "nvim-treesitter/nvim-treesitter" },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "css", "scss", "html", "yaml", "markdown" },
    config = function()
      require("configs.null-ls")
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettierd",
        "ruff",
        "black",
        "isort",
        "ts_ls",
        "typescript-language-server",
        "tailwindcss-language-server",
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = "nvim-treesitter/nvim-treesitter",
    lazy = false
  },
  -- LuaSnip and friendly snippets for snippets
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local luasnip = require("luasnip")
      luasnip.filetype_extend("typescriptreact", { "html" })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "rafamadriz/friendly-snippets",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
