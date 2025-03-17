-- ===========================================================================
--                             AUTO COMMANDS
-- ===========================================================================

-- Open NvimTree on VimEnter if opening a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      require('nvim-tree.api').tree.open()
    end
  end,
  desc = "Open NvimTree when opening a directory",
})

-- Close NvimTree when the cursor leaves its window
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    if require("nvim-tree.view").is_visible() then
      vim.cmd("NvimTreeClose")
    end
  end,
  desc = "Close NvimTree when cursor leaves the sidebar",
})

-- Set indentation for Python files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})
-- ===========================================================================
--                            MACRO NOTIFICATIONS
-- ===========================================================================

local function notify_macro_start()
  local register = vim.fn.reg_recording()
  if register ~= "" then
    vim.notify("Start recording @" .. register, "info", { title = "Macro" })
  end
end

local function notify_macro_end()
  local register = vim.fn.reg_recording()
  if register ~= "" then
    vim.notify("Stopped recording @" .. register, "info", { title = "Macro" })
  else
    vim.notify("Recording stopped!", "info", { title = "Macro" })
  end
end

-- Auto commands for macro recording notifications
vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = notify_macro_start,
  desc = "Notify when macro recording starts",
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = notify_macro_end,
  desc = "Notify when macro recording stops",
})
