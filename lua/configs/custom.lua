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

-- Function to copy the content of all visible buffers to the clipboard
local function copy_buffers_to_clipboard()
  local result = {} -- Table to store the aggregated content

  -- Get the project root (directory where Neovim was opened)
  local project_root = vim.loop.cwd()

  -- Iterate over all visible buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- Check if the buffer is valid, listed, and has a name (file path)
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      if file_path ~= "" then
        -- Compute the relative path from the project root
        local relative_path = vim.fn.fnamemodify(file_path, ":.")
        relative_path = vim.fn.substitute(relative_path, "^" .. vim.fn.escape(project_root, "/"), "", "")

        -- Add the relative file path as a header
        table.insert(result, "File: " .. relative_path .. "\n")

        -- Get the content of the buffer
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        table.insert(result, table.concat(lines, "\n") .. "\n\n")
      end
    end
  end

  -- Combine all content into a single string
  local aggregated_content = table.concat(result)

  -- Copy the content to the system clipboard
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content) -- Use '+' register for system clipboard
    print("Buffer contents copied to clipboard!")
  else
    print("Clipboard support not available. Please ensure Neovim is built with clipboard support.")
  end
end

-- Create a custom command :CopyBuffersToClipboard
vim.api.nvim_create_user_command('CopyBuffersToClipboard', copy_buffers_to_clipboard, {})

-- Function to copy the content of Harpoon-marked files to the clipboard
local function copy_harpoon_files_to_clipboard()
  -- Ensure Harpoon is loaded
  local harpoon = require("harpoon")

  -- Get the project root (directory where Neovim was opened)
  local project_root = vim.loop.cwd()

  -- Retrieve the list of Harpoon-marked files
  local marks = harpoon.get_mark_config().marks -- Correct API call
  if #marks == 0 then
    print("No files marked in Harpoon.")
    return
  end

  local result = {} -- Table to store the aggregated content

  -- Iterate over Harpoon-marked files
  for _, mark in ipairs(marks) do
    local file_path = mark.filename -- Extract the file path from the mark

    -- Compute the relative path from the project root
    local relative_path = vim.fn.fnamemodify(file_path, ":.")
    relative_path = vim.fn.substitute(relative_path, "^" .. vim.fn.escape(project_root, "/"), "", "")

    -- Add the relative file path as a header
    table.insert(result, "File: " .. relative_path .. "\n")

    -- Get the content of the file
    local lines = {}
    local file = io.open(file_path, "r")
    if file then
      for line in file:lines() do
        table.insert(lines, line)
      end
      file:close()
    else
      table.insert(lines, "-- File could not be read --")
    end

    table.insert(result, table.concat(lines, "\n") .. "\n\n")
  end

  -- Combine all content into a single string
  local aggregated_content = table.concat(result)

  -- Copy the content to the system clipboard
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content) -- Use '+' register for system clipboard
    print("Harpoon-marked file contents copied to clipboard!")
  else
    print("Clipboard support not available. Please ensure Neovim is built with clipboard support.")
  end
end

-- Create a custom command :CopyHarpoonFilesToClipboard
vim.api.nvim_create_user_command('CopyHarpoonFilesToClipboard', copy_harpoon_files_to_clipboard, {})
