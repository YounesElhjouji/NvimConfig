require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "lua",
    "python",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "jsx",
    "tsx",
    "html",
    "css",
    "hbs",
    "prisma"
  }, -- or other languages you use
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true
  }
  -- add any other configuration options you need
}
