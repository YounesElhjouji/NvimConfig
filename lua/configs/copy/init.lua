-- copy/init.lua
local commands = require("configs.copy.commands")

-- Expose the commands
return {
  copy_buffers_to_clipboard = commands.copy_buffers_to_clipboard,
  copy_git_files_to_clipboard = commands.copy_git_files_to_clipboard,
  copy_quickfix_files_to_clipboard = commands.copy_quickfix_files_to_clipboard,
  copy_harpoon_files_to_clipboard = commands.copy_harpoon_files_to_clipboard,
  copy_directory_files_to_clipboard = commands.copy_directory_files_to_clipboard,
}
