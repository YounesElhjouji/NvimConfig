local tabufline = require("nvchad.tabufline")


-- Define custom commands for closing buffers
vim.api.nvim_create_user_command("CloseLeft", function()
  tabufline.closeBufs_at_direction("left")
end, { desc = "Close tabs to the left" })

vim.api.nvim_create_user_command("CloseRight", function()
  tabufline.closeBufs_at_direction("right")
end, { desc = "Close tabs to the right" })

vim.api.nvim_create_user_command("CloseOthers", function()
  tabufline.closeAllBufs(false)
end, { desc = "Close other tabs" })
