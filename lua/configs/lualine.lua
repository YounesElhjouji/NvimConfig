-- Initialize lualine with the statusline hidden by default.
require("lualine").setup({
  options = {
    laststatus = 0, -- 0: never show statusline
  },
})
