vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(data)
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

-- Exit nvim tree when leaving its window
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    if require("nvim-tree.view").is_visible() then
      vim.cmd("NvimTreeClose")
    end
  end,
  desc = "Close nvim-tree when cursor leaves the sidebar",
})

-- PEP8 settings for Python files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 4
    vim.opt_local.foldmethod = 'indent'
  end,
})


vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == "pyright" then
      vim.bo[args.buf].tabstop = 4
      vim.bo[args.buf].shiftwidth = 4
      vim.bo[args.buf].expandtab = true
      vim.bo[args.buf].softtabstop = 4
    end
  end,
})

require("configs.copy_logic")

-- Create custom commands for copying files
vim.api.nvim_create_user_command('CopyBuffersToClipboard', CopyBuffersToClipboard, {})
vim.api.nvim_create_user_command('CopyHarpoonFilesToClipboard', CopyHarpoonFilesToClipboard, {})
vim.api.nvim_create_user_command('CopyGitFilesToClipboard', CopyGitFilesToClipboard, {})
vim.api.nvim_create_user_command('CopyQuickfixFilesToClipboard', CopyQuickfixFilesToClipboard, {})
vim.api.nvim_create_user_command('CopyDirectoryFilesToClipboard', function(opts)
  if opts.args == "" then
    print("Please specify a directory.")
  else
    CopyDirectoryFilesToClipboard(opts.args)
  end
end, { nargs = 1 })
