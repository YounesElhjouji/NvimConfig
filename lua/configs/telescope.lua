require('telescope').setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      "venv/", -- Add this line to ignore venv/ directories
    },
  },
})
