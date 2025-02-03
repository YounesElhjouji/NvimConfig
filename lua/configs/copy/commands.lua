local clipboard = require("configs.copy.clipboard")
local file_utils = require("configs.copy.file_utils")

local M = {}

-- Helper: merge opts with defaults.
-- Default preserve_folds is true and default recursive is true.
local function default_opts(opts)
  opts = opts or {}
  if opts.preserve_folds == nil then
    opts.preserve_folds = true
  end
  if opts.recursive == nil then
    opts.recursive = true
  end
  return opts
end

-- Copy content of all visible buffers to the clipboard.
function M.copy_buffers_to_clipboard(opts)
  opts = default_opts(opts)
  local files = {}
  local seen_files = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      if file_path ~= "" and not seen_files[file_path] then
        seen_files[file_path] = true
        table.insert(files, file_path)
      end
    end
  end
  clipboard.copy_to_clipboard_from_files(files, "Buffer", { preserve_folds = opts.preserve_folds })
end

-- Copy the current (focused) buffer to the clipboard.
function M.copy_current_buffer_to_clipboard(opts)
  opts = default_opts(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  if file_path == "" then
    print("Current buffer is not associated with a file.")
    return
  end

  clipboard.copy_to_clipboard_from_files({ file_path }, "Git-modified file", { preserve_folds = opts.preserve_folds })
end

-- Copy content of files modified in Git to the clipboard.
function M.copy_git_files_to_clipboard(opts)
  opts = default_opts(opts)
  local git_files = vim.fn.systemlist("git diff --name-only HEAD")
  if #git_files == 0 then
    print("No modified files in Git.")
    return
  end
  clipboard.copy_to_clipboard_from_files(git_files, "Git-modified file", { preserve_folds = opts.preserve_folds })
end

-- Copy content of files from the quickfix list to the clipboard.
function M.copy_quickfix_files_to_clipboard(opts)
  opts = default_opts(opts)
  local qf_list = vim.fn.getqflist()
  if #qf_list == 0 then
    print("Quickfix list is empty.")
    return
  end

  local files = {}
  local seen_files = {}
  for _, entry in ipairs(qf_list) do
    local file_path = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)
    if file_path and file_path ~= "" and not seen_files[file_path] then
      seen_files[file_path] = true
      table.insert(files, file_path)
    end
  end

  if #files == 0 then
    print("No valid files found in the quickfix list.")
    return
  end
  clipboard.copy_to_clipboard_from_files(files, "Quickfix file", { preserve_folds = opts.preserve_folds })
end

-- Copy content of files marked in Harpoon to the clipboard.
function M.copy_harpoon_files_to_clipboard(opts)
  opts = default_opts(opts)
  local harpoon = require("harpoon")
  local marks = harpoon.get_mark_config().marks
  if #marks == 0 then
    print("No files marked in Harpoon.")
    return
  end

  local paths = {}
  for _, mark in ipairs(marks) do
    if mark.filename then
      table.insert(paths, mark.filename)
    end
  end

  local all_files = file_utils.process_paths(paths, opts.recursive)
  if #all_files == 0 then
    print("No valid files found in Harpoon marks.")
    return
  end
  clipboard.copy_to_clipboard_from_files(all_files, "Harpoon", { preserve_folds = opts.preserve_folds })
end

-- Copy content of files from a directory to the clipboard.
-- Accepts an optional second argument 'opts' with opts.recursive and opts.preserve_folds.
function M.copy_directory_files_to_clipboard(directory, opts)
  opts = default_opts(opts)
  local recursive = opts.recursive

  if not directory or directory == "" then
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == "" then
      print("No directory specified and no file in current buffer.")
      return
    end
    directory = vim.fn.fnamemodify(current_file, ":h")
  end

  if vim.fn.isdirectory(directory) == 0 then
    print("Invalid directory: " .. directory)
    return
  end

  local all_files = file_utils.process_paths({ directory }, recursive)
  if #all_files == 0 then
    print("No files found in directory: " .. directory)
    return
  end
  clipboard.copy_to_clipboard_from_files(all_files, "Directory", { preserve_folds = opts.preserve_folds })
end

return M
