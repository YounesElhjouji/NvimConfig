local utils = require("configs.copy.utils")

local M = {}

-- Shared function to recursively collect files from directories
function M.get_all_files(path)
  local files = {}
  if vim.fn.isdirectory(path) == 1 then
    local items = vim.fn.glob(path .. "/*", true, true)
    for _, item in ipairs(items) do
      if vim.fn.isdirectory(item) == 1 then
        for _, f in ipairs(M.get_all_files(item)) do
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
function M.process_paths(paths)
  local all_files = {}
  for _, path in ipairs(paths) do
    for _, f in ipairs(M.get_all_files(path)) do
      table.insert(all_files, f)
    end
  end
  return all_files
end

return M
