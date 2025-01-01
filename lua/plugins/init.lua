return {
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
    "numtostr/BufOnly.nvim",
    lazy = false,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
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
