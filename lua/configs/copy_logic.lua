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

-- Function to copy the content of all visible buffers to the clipboard
function CopyBuffersToClipboard()
  local result = {}
  local seen_files = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      if file_path ~= "" and not seen_files[file_path] then
        seen_files[file_path] = true
        local relative_path = get_relative_path(file_path)
        table.insert(result, "File: " .. relative_path .. "\n")
        table.insert(result, read_file_content(file_path) .. "\n\n")
      end
    end
  end
  local aggregated_content = table.concat(result)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print(string.format("Buffer contents of %d files copied to clipboard!", #result / 2))
  else
    print("Clipboard support not available.")
  end
end

-- Function to copy files from Git changes
function CopyGitFilesToClipboard()
  local git_files = vim.fn.systemlist("git diff --name-only HEAD") -- Get modified files
  if #git_files == 0 then
    print("No modified files in Git.")
    return
  end
  local result = {}
  local seen_files = {}
  for _, file_path in ipairs(git_files) do
    if file_path and not seen_files[file_path] then
      seen_files[file_path] = true
      local relative_path = get_relative_path(file_path)
      table.insert(result, "File: " .. relative_path .. "\n")
      table.insert(result, read_file_content(file_path) .. "\n\n")
    end
  end
  local aggregated_content = table.concat(result)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print(string.format("Git-modified file contents of %d files copied to clipboard!", #result / 2))
  else
    print("Clipboard support not available.")
  end
end

-- Function to copy files from the quickfix list
function CopyQuickfixFilesToClipboard()
  local qf_list = vim.fn.getqflist() -- Get quickfix list entries
  if #qf_list == 0 then
    print("Quickfix list is empty.")
    return
  end
  local result = {}
  local seen_files = {} -- Track files to avoid duplicates
  for _, entry in ipairs(qf_list) do
    local bufnr = entry.bufnr
    local file_path = entry.filename or vim.api.nvim_buf_get_name(bufnr)
    -- Skip invalid or duplicate files
    if file_path and file_path ~= "" and not seen_files[file_path] then
      seen_files[file_path] = true -- Mark file as seen
      local relative_path = get_relative_path(file_path)
      table.insert(result, "File: " .. relative_path .. "\n")
      table.insert(result, read_file_content(file_path) .. "\n\n")
    end
  end
  if #result == 0 then
    print("No valid files found in the quickfix list.")
    return
  end
  -- Combine all content into a single string
  local aggregated_content = table.concat(result)
  -- Copy the content to the system clipboard
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print(string.format("Quickfix file contents of %d files copied to clipboard!", #result / 2))
  else
    print("Clipboard support not available.")
  end
end

-- Shared utility function to recursively collect files from directories
local function get_all_files(path, seen)
  local files = {}
  if vim.fn.isdirectory(path) == 1 then
    local items = vim.fn.glob(path .. "/*", true, true)
    for _, item in ipairs(items) do
      if vim.fn.isdirectory(item) == 1 then
        local sub_files = get_all_files(item)
        for _, f in ipairs(sub_files) do
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

-- Shared function to process multiple paths (files/directories)
local function process_paths(paths)
  local all_files = {}
  for _, path in ipairs(paths) do
    local files = get_all_files(path)
    for _, f in ipairs(files) do
      table.insert(all_files, f)
    end
  end
  return all_files
end

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

-- Updated Harpoon function
function CopyHarpoonFilesToClipboard()
  local harpoon = require("harpoon")
  local marks = harpoon.get_mark_config().marks
  if #marks == 0 then
    print("No files marked in Harpoon.")
    return
  end

  -- Collect all marked paths
  local paths = {}
  for _, mark in ipairs(marks) do
    if mark.filename then
      table.insert(paths, mark.filename)
    end
  end

  -- Process paths (files and directories)
  local all_files = process_paths(paths)
  if #all_files == 0 then
    print("No valid files found in Harpoon marks.")
    return
  end

  -- Build and copy content
  local result = build_content_buffer(all_files)
  local aggregated_content = table.concat(result)

  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print(string.format("Harpoon contents (%d files) copied to clipboard!", #all_files))
  else
    print("Clipboard support not available.")
  end
end

-- Updated Directory function
function CopyDirectoryFilesToClipboard(directory)
  -- Default to current buffer's parent directory if not specified
  if not directory or directory == "" then
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == "" then
      print("No directory specified and no file in current buffer.")
      return
    end
    directory = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Validate directory
  if vim.fn.isdirectory(directory) == 0 then
    print("Invalid directory: " .. directory)
    return
  end

  -- Process directory
  local all_files = process_paths({ directory })
  if #all_files == 0 then
    print("No files found in directory: " .. directory)
    return
  end

  -- Build and copy content
  local result = build_content_buffer(all_files)
  local aggregated_content = table.concat(result)

  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print(string.format("Directory contents (%d files) copied to clipboard!", #all_files))
  else
    print("Clipboard support not available.")
  end
end
