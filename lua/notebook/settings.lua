local M = {}

-- M.plugin_namespace = vim.api.nvim_create_namespace("notebook")
M.virtual_text_namespace = vim.api.nvim_create_namespace("notebook.virtual")
M.virtual_text_hl_group = "notebook_virtual_text"
M.virtual_text_style = { fg = "lightblue", italic = true }
M.empty_notebook = {
    cells = {},
    metadata = {
        kernelspec = {},
    },
    nbformat = 4,
    nbformat_minor = 5,
}
M.comment_markers = {
    python = { start = '"""', finish = '"""' },
    r = { start = '"', finish = '"' },
    julia = { start = '#=', finish = '=#' }
}
M.extmarks = {}
M.options = {
    insert_blank_line = true
}

return M
