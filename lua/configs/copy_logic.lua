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

-- Function to copy the content of Harpoon-marked files to the clipboard
function CopyHarpoonFilesToClipboard()
  local harpoon = require("harpoon")
  local marks = harpoon.get_mark_config().marks
  if #marks == 0 then
    print("No files marked in Harpoon.")
    return
  end
  local result = {}
  local seen_files = {}
  for _, mark in ipairs(marks) do
    local file_path = mark.filename
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
    print(string.format("Harpoon-marked file contents of %d files copied to clipboard!", #result / 2))
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

-- Function to copy files from a specific directory recursively
function CopyDirectoryFilesToClipboard(directory)
  -- If no directory is specified, use the parent directory of the current buffer
  if directory == "" then
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == "" then
      print("No directory specified and no file in the current buffer.")
      return
    end
    directory = vim.fn.fnamemodify(current_file, ":h") -- Get the parent directory
  end

  -- Ensure the directory exists
  if not vim.fn.isdirectory(directory) then
    print("The specified path is not a valid directory.")
    return
  end

  -- Recursive function to traverse directories and collect files
  local function collect_files(dir)
    local files = {}
    local items = vim.fn.glob(dir .. "/*", true, true) -- Get all items in the directory
    for _, item in ipairs(items) do
      if vim.fn.isdirectory(item) == 1 then
        -- Recursively collect files from subdirectories
        local sub_files = collect_files(item)
        for _, sub_file in ipairs(sub_files) do
          table.insert(files, sub_file)
        end
      else
        -- Add the file to the list
        table.insert(files, item)
      end
    end
    return files
  end

  -- Collect all files recursively
  local all_files = collect_files(directory)

  -- If no files are found, exit early
  if #all_files == 0 then
    print("No files found in the specified directory.")
    return
  end

  -- Prepare the result with file contents
  local result = {}
  for _, file_path in ipairs(all_files) do
    local relative_path = get_relative_path(file_path)
    table.insert(result, "File: " .. relative_path .. "\n")
    table.insert(result, read_file_content(file_path) .. "\n\n")
  end

  -- Combine all content into a single string
  local aggregated_content = table.concat(result)

  -- Copy the content to the system clipboard
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print(string.format("Copied %d files to clipboard!", #all_files))
  else
    print("Clipboard support not available.")
  end
end
