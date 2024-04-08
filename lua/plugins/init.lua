return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    lazy=false,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
   "neovim/nvim-lspconfig",
   config = function()
     require("nvchad.configs.lspconfig").defaults()
     require "configs.lspconfig"
   end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server", "stylua",
        "html-lsp", "css-lsp" , "prettier",
        "ruff-lsp", "black", "isort"
      },
    },
  },

  {
    "ThePrimeagen/vim-be-good",
    lazy=false
  }
  --
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
