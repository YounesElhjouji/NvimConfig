require("dashboard").setup {
  theme = 'doom',
  config = {
    header = {
      "                                                      ",
      "                                                      ",
      "                                                      ",
      "                                                      ",
      "▓██   ██▓ ▒█████   █    ██  ███▄    █ ▓█████   ██████ ",
      " ▒██  ██▒▒██▒  ██▒ ██  ▓██▒ ██ ▀█   █ ▓█   ▀ ▒██    ▒ ",
      "  ▒██ ██░▒██░  ██▒▓██  ▒██░▓██  ▀█ ██▒▒███   ░ ▓██▄   ",
      "  ░ ▐██▓░▒██   ██░▓▓█  ░██░▓██▒  ▐▌██▒▒▓█  ▄   ▒   ██▒",
      "  ░ ██▒▓░░ ████▓▒░▒▒█████▓ ▒██░   ▓██░░▒████▒▒██████▒▒",
      "   ██▒▒▒ ░ ▒░▒░▒░ ░▒▓▒ ▒ ▒ ░ ▒░   ▒ ▒ ░░ ▒░ ░▒ ▒▓▒ ▒ ░",
      " ▓██ ░▒░   ░ ▒ ▒░ ░░▒░ ░ ░ ░ ░░   ░ ▒░ ░ ░  ░░ ░▒  ░ ░",
      " ▒ ▒ ░░  ░ ░ ░ ▒   ░░░ ░ ░    ░   ░ ░    ░   ░  ░  ░  ",
      " ░ ░         ░ ░     ░              ░    ░  ░      ░  ",
      " ░ ░                                                  ",
      "                                                      ",
      "                                                      ",
    },
    -- Centered buttons for quick actions
    center = {
      {
        icon = "  ",
        desc = "Recently opened files                 ",
        action = "Telescope oldfiles",
        key = "r",
      },
      {
        icon = "  ",
        desc = "Find File                             ",
        action = "Telescope find_files",
        key = "f",
      },
      {
        icon = "  ",
        desc = "Find word                             ",
        action = "Telescope live_grep",
        key = "w",
      },
      {
        icon = "  ",
        desc = "Open Neovim config                    ",
        action = "edit ~/.config/nvim/init.lua",
        key = "c",
      },
      {
        icon = "  ",
        desc = "Quit Neovim                           ",
        action = "qa", -- Use "qa" for quit all
        key = "q",
      },
    },
    footer = {
      "ُهَرَي اًرْيَخ ٍةَّرَذ ل اقْثِم ْلَمْعَي نَمَف"
      -- "Akhdem a ss7aybi la gha tkhdem!",
    },
  },
}

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, 'DashboardFooter', {
      fg = '#FFFFFF',
      bg = '#1E222A',
      bold = true,
      height = 15
    })
  end,
})
