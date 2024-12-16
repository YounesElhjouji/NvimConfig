-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "pyright", "ruff", "ts_ls", "tailwindcss", "lua-language-server", "eslint" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = { "*.py", "*.js*", "*.ts*" },
  callback = function()
    vim.lsp.buf.format { async = false }
  end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.py",
  callback = function()
    local context = { only = { "source.fixAll" } }
    vim.lsp.buf.code_action { context = context, apply = true }
  end,
})

--   cmd = { 'kotlin-language-server' },
--   filetypes = { 'kotlin' },
--   root_dir = lspconfig.util.root_pattern('settings.gradle', 'settings.gradle.kts', '.git'),
--   settings = {
--     kotlin = {
--       compiler = {
--         jvm = {
--           target = "1.8"
--         }
--       }
--     }
--   },
--   on_attach = on_attach
-- }

-- auto formatting

