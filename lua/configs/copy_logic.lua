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
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      if file_path ~= "" then
        local relative_path = get_relative_path(file_path)
        table.insert(result, "File: " .. relative_path .. "\n")
        table.insert(result, read_file_content(file_path) .. "\n\n")
      end
    end
  end
  local aggregated_content = table.concat(result)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print("Buffer contents copied to clipboard!")
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
  for _, mark in ipairs(marks) do
    local file_path = mark.filename
    local relative_path = get_relative_path(file_path)
    table.insert(result, "File: " .. relative_path .. "\n")
    table.insert(result, read_file_content(file_path) .. "\n\n")
  end
  local aggregated_content = table.concat(result)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print("Harpoon-marked file contents copied to clipboard!")
  else
    print("Clipboard support not available.")
  end
end

-- Function to copy files from Git changes
function CopyGitFilesToClipboard()
  local git_files = vim.fn.systemlist("git diff --name-only HEAD") -- Get modified files <button class="citation-flag" data-index="6">
  if #git_files == 0 then
    print("No modified files in Git.")
    return
  end
  local result = {}
  for _, file_path in ipairs(git_files) do
    local relative_path = get_relative_path(file_path)
    table.insert(result, "File: " .. relative_path .. "\n")
    table.insert(result, read_file_content(file_path) .. "\n\n")
  end
  local aggregated_content = table.concat(result)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print("Git-modified file contents copied to clipboard!")
  else
    print("Clipboard support not available.")
  end
end

-- Function to copy files from the quickfix list
function CopyQuickfixFilesToClipboard()
  local qf_list = vim.fn.getqflist()   -- Get quickfix list entries <button class="citation-flag" data-index="1">
  if #qf_list == 0 then
    print("Quickfix list is empty.")
    return
  end

  local result = {}
  local seen_files = {}   -- Track files to avoid duplicates

  for _, entry in ipairs(qf_list) do
    local bufnr = entry.bufnr
    local file_path = entry.filename or
    vim.api.nvim_buf_get_name(bufnr)                                         -- Use filename or derive from bufnr <button class="citation-flag" data-index="2">

    -- Skip invalid or duplicate files
    if file_path and file_path ~= "" and not seen_files[file_path] then
      seen_files[file_path] = true       -- Mark file as seen
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
    print("Quickfix file contents copied to clipboard!")
  else
    print("Clipboard support not available.")
  end
end

-- Function to copy files from a specific directory
function CopyDirectoryFilesToClipboard(directory)
  local files = vim.fn.glob(directory .. "/*", true, true) -- Get all files in the directory <button class="citation-flag" data-index="9">
  if #files == 0 then
    print("No files found in the specified directory.")
    return
  end
  local result = {}
  for _, file_path in ipairs(files) do
    if vim.fn.isdirectory(file_path) == 0 then -- Skip directories
      local relative_path = get_relative_path(file_path)
      table.insert(result, "File: " .. relative_path .. "\n")
      table.insert(result, read_file_content(file_path) .. "\n\n")
    end
  end
  local aggregated_content = table.concat(result)
  if vim.fn.has('clipboard') == 1 then
    vim.fn.setreg('+', aggregated_content)
    print("Directory file contents copied to clipboard!")
  else
    print("Clipboard support not available.")
  end
end
