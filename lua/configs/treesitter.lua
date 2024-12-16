require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "lua",
    "python",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "tsx",
    "javascript",
    "html",
    "css",
    "hbs"
  }, -- or other languages you use
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  -- add any other configuration options you need
}
