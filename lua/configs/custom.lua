vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function (data)
   if vim.fn.isdirectory(data.file) == 1 then
    require('nvim-tree.api').tree.open()
    end
  end,
  -- this fires on VimEnter regardless of filename, so check the directory
  desc = "Open NvimTree on VimEnter",
})
