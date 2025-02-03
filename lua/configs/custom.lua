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


-- ===========================================================================
--                      COMPARE CLIPBOARD WITH CURRENT FILE
-- ===========================================================================

local function CompareWithClipboard()
  -- Get the current buffer file extension (preserve syntax highlighting)
  local bufname = vim.api.nvim_buf_get_name(0)
  local ext = bufname:match("^.+(%..+)$") or ""  -- Extract extension (e.g., ".ts", ".lua")
  local temp_file = "/tmp/nvim_diff_temp" .. ext -- Preserve extension

  -- Ensure no previous temp file exists
  os.remove(temp_file)

  -- Open a new scratch buffer and paste clipboard contents
  vim.cmd('new')
  vim.cmd('setlocal buftype=nofile')
  vim.cmd('read !pbpaste') -- Use macOS pbpaste for clipboard content

  -- Save buffer to a temporary file with the correct extension
  vim.cmd('silent write! ' .. temp_file)
  vim.cmd('bdelete') -- Close temp buffer

  -- Open a vertical diff split with the current file
  vim.cmd('vert diffsplit ' .. temp_file)
end

local function CloseDiffView()
  vim.cmd('diffoff!') -- Disable diff mode
  vim.cmd('bdelete!') -- Close temp buffer
end

vim.api.nvim_create_user_command('DiffClipboard', CompareWithClipboard, {
  desc = "Compare clipboard content with the current buffer using diff mode",
})

vim.api.nvim_create_user_command('DiffClose', CloseDiffView, {
  desc = "Close diff mode and delete temp buffer",
})

-- Keybindings
vim.api.nvim_set_keymap('n', '<leader>dc', ':DiffClipboard<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>df', ':DiffClose<CR>', { noremap = true, silent = true })


-- ===========================================================================
--                      COPY FILES HELPERS
-- ===========================================================================

local copy_commands = require("configs.copy.commands")

-- Create custom commands for copying files
vim.api.nvim_create_user_command('CopyBuffersToClipboard', copy_commands.copy_buffers_to_clipboard, {})
vim.api.nvim_create_user_command('CopyHarpoonFilesToClipboard', copy_commands.copy_harpoon_files_to_clipboard, {})
vim.api.nvim_create_user_command('CopyGitFilesToClipboard', copy_commands.copy_git_files_to_clipboard, {})
vim.api.nvim_create_user_command('CopyQuickfixFilesToClipboard', copy_commands.copy_quickfix_files_to_clipboard, {})
vim.api.nvim_create_user_command('CopyDirectoryFilesToClipboard', function(opts)
  local directory = opts.args ~= "" and opts.args or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
  copy_commands.copy_directory_files_to_clipboard(directory)
end, { nargs = "?" })
