require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map({ "n", "x" }, ":", ";", { desc = "Next search movement" })
map({ "n", "x" }, ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- LSP mappings
map("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>")
map("n", "gD", "<CMD>lua vim.lsp.buf.declaration()<CR>")
map("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<CR>")
map("n", "gr", "<CMD>lua vim.lsp.buf.references()<CR>")
map("n", "K", "<CMD>lua vim.lsp.buf.hover()<CR>")
map("n", "gR", "<CMD>lua vim.lsp.buf.rename()<CR>")
map("n", "ga", "<CMD>lua vim.lsp.buf.code_action()<CR>")

-- 
map({"n", "x"}, "<leader>e", "<CMD>NvimTreeToggle<CR>")



-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
