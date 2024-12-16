vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function (data)
   if vim.fn.isdirectory(data.file) == 1 then
    require('nvim-tree.api').tree.open()
    end
  end,
  -- this fires on VimEnter regardless of filename, so check the directory
  desc = "Open NvimTree on VimEnter",
})

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

-- Create autocommands for macro recording
vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = notify_macro_start,
  desc = "Notify when macro recording starts"
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = notify_macro_end,
  desc = "Notify when macro recording stops"
})
