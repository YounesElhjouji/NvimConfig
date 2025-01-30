local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Existing prettierd source
    null_ls.builtins.formatting.prettierd, -- Prettierd for JS/TS/HTML/CSS

    -- Add Python formatters
    null_ls.builtins.formatting.black, -- Black for Python formatting
    null_ls.builtins.formatting.isort, -- isort for organizing Python imports
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
