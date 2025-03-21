-- Initialize lualine with the statusline hidden by default.
require("lualine").setup({
  options = {
    theme = "catppuccin",
    laststatus = 0, -- 0: never show statusline
  },
})
