local none_ls = require("null-ls")

none_ls.setup({
  sources = {
    none_ls.builtins.formatting.prettierd, -- Use prettierd for formatting
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
