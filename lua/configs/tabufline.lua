local tabufline = require("nvchad.tabufline")


-- Close buffers to the left of current buffer
vim.api.nvim_create_user_command("CloseLeft", function()
  tabufline.closeBufs_at_direction("left")
end, { desc = "Close tabs to the left" })

-- Close buffers to the right of current buffer
vim.api.nvim_create_user_command("CloseRight", function()
  tabufline.closeBufs_at_direction("right")
end, { desc = "Close tabs to the right" })

-- Close all other buffers except current
vim.api.nvim_create_user_command("CloseOthers", function()
  tabufline.closeAllBufs(false)
end, { desc = "Close other tabs" })
