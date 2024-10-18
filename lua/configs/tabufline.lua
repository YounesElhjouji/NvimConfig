
local function get_tab_name(bufnr)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    if vim.fn.bufname(bufnr) ~= "" then
        local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:h")
        return vim.fn.pathshorten(buf_path) .. "/" .. name
    end
    return name
end

require('tabufline').setup {
    custom_names = get_tab_name
}
