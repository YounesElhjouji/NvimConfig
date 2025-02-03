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

-- Helper function: parse command-line arguments (fargs) into options.
-- Recognizes:
--    "nofolds"   => sets preserve_folds = false
--    "norecurse" => sets recursive = false
local function parse_flags(args)
  local opts = {}
  for _, arg in ipairs(args) do
    local flag = arg:lower()
    if flag == "nofolds" then
      opts.preserve_folds = false
    elseif flag == "norecurse" then
      opts.recursive = false
    end
  end
  return opts
end

-- Create custom commands for copying files.
-- All commands now accept optional flags via nargs = "*" which are parsed and passed along.

vim.api.nvim_create_user_command(
  'CopyBuffersToClipboard',
  function(opts)
    local flags = parse_flags(opts.fargs or {})
    copy_commands.copy_buffers_to_clipboard(flags)
  end,
  { nargs = "*" }
)

vim.api.nvim_create_user_command(
  'CopyHarpoonFilesToClipboard',
  function(opts)
    -- For Harpoon, support norecurse and nofolds.
    local flags = parse_flags(opts.fargs or {})
    copy_commands.copy_harpoon_files_to_clipboard(flags)
  end,
  { nargs = "*" }
)

vim.api.nvim_create_user_command(
  'CopyGitFilesToClipboard',
  function(opts)
    local flags = parse_flags(opts.fargs or {})
    copy_commands.copy_git_files_to_clipboard(flags)
  end,
  { nargs = "*" }
)

vim.api.nvim_create_user_command(
  'CopyQuickfixFilesToClipboard',
  function(opts)
    local flags = parse_flags(opts.fargs or {})
    copy_commands.copy_quickfix_files_to_clipboard(flags)
  end,
  { nargs = "*" }
)

vim.api.nvim_create_user_command(
  'CopyDirectoryFilesToClipboard',
  function(opts)
    local dir = nil
    local flags = {}
    -- If at least one argument is provided...
    if #opts.fargs > 0 then
      -- Check if the first argument is a valid directory.
      if vim.fn.isdirectory(opts.fargs[1]) == 1 then
        dir = opts.fargs[1]
        -- The remaining arguments (if any) are flags.
        for i = 2, #opts.fargs do
          table.insert(flags, opts.fargs[i])
        end
      else
        -- No valid directory provided; use current buffer's directory,
        -- and treat all arguments as flags.
        flags = opts.fargs
      end
    else
      -- No arguments passed: use current buffer's directory.
      dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    end
    local flags_opts = parse_flags(flags)
    copy_commands.copy_directory_files_to_clipboard(dir, flags_opts)
  end,
  { nargs = "*" }
)

vim.api.nvim_create_user_command(
  'CopyCurrentBufferToClipboard',
  function(opts)
    local flags = parse_flags(opts.fargs or {})
    copy_commands.copy_current_buffer_to_clipboard(flags)
  end,
  { nargs = "*" }
)
