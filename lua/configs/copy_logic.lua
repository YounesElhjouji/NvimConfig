-- Utility function to compute relative paths
local function get_relative_path(file_path)
  local project_root = vim.loop.cwd()
  local relative_path = vim.fn.fnamemodify(file_path, ":.")
  return vim.fn.substitute(relative_path, "^" .. vim.fn.escape(project_root, "/"), "", "")
end

-- Utility function to read file content
local function read_file_content(file_path)
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
  return table.concat(lines, "\n")
end

-- Shared function to recursively collect files from directories
local function get_all_files(path)
  local files = {}
  if vim.fn.isdirectory(path) == 1 then
    local items = vim.fn.glob(path .. "/*", true, true)
    for _, item in ipairs(items) do
      if vim.fn.isdirectory(item) == 1 then
        for _, f in ipairs(get_all_files(item)) do
          table.insert(files, f)
        end
      else
        table.insert(files, item)
      end
    end
  else
    table.insert(files, path)
  end
  return files
end

-- Process a list of paths (files and/or directories) into a flat list of files
local function process_paths(paths)
  local all_files = {}
  for _, path in ipairs(paths) do
    for _, f in ipairs(get_all_files(path)) do
      table.insert(all_files, f)
    end
  end
  return all_files
end

-- Build a content buffer from a list of files.
-- Each file is represented as two entries in the returned table:
-- one for the header and one for its content.
local function build_content_buffer(files)
  local result = {}
  local seen_files = {}
  for _, file_path in ipairs(files) do
    if file_path and not seen_files[file_path] then
      seen_files[file_path] = true
      local relative_path = get_relative_path(file_path)
      table.insert(result, "File: " .. relative_path .. "\n")
      table.insert(result, read_file_content(file_path) .. "\n\n")
    end
  end
  return result
end

-- Helper function to build the content from files and copy it to the clipboard.
-- `source` is used in the printed message.
local function copy_to_clipboard_from_files(files, source)
  local content_buffer = build_content_buffer(files)
  if #content_buffer == 0 then
    print("No valid files found for " .. source .. ".")
    return
  end

  local aggregated_content = table.concat(content_buffer)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    -- Since each file contributes two entries (header and content),
    -- we divide the total number of lines by 2 to get the file count.
    local file_count = #content_buffer / 2
    print(string.format("%s contents of %d files copied to clipboard!", source, file_count))
  else
    print("Clipboard support not available.")
  end
end

-----------------------------------------------------------
-- Higher-level functions that gather files then delegate to
-- the shared copy_to_clipboard_from_files() helper.
-----------------------------------------------------------

-- Copy content of all visible buffers to the clipboard.
function CopyBuffersToClipboard()
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
  copy_to_clipboard_from_files(files, "Buffer")
end

-- Copy content of files modified in Git to the clipboard.
function CopyGitFilesToClipboard()
  local git_files = vim.fn.systemlist("git diff --name-only HEAD")
  if #git_files == 0 then
    print("No modified files in Git.")
    return
  end
  copy_to_clipboard_from_files(git_files, "Git-modified file")
end

-- Copy content of files from the quickfix list to the clipboard.
function CopyQuickfixFilesToClipboard()
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
  copy_to_clipboard_from_files(files, "Quickfix file")
end

-- Copy content of files marked in Harpoon to the clipboard.
function CopyHarpoonFilesToClipboard()
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

  local all_files = process_paths(paths)
  if #all_files == 0 then
    print("No valid files found in Harpoon marks.")
    return
  end
  copy_to_clipboard_from_files(all_files, "Harpoon")
end

-- Copy content of files from a directory to the clipboard.
-- If no directory is specified, uses the current buffer's parent directory.
function CopyDirectoryFilesToClipboard(directory)
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

  local all_files = process_paths({ directory })
  if #all_files == 0 then
    print("No files found in directory: " .. directory)
    return
  end
  copy_to_clipboard_from_files(all_files, "Directory")
end
