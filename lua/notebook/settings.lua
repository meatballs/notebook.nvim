local M = {}

M.virtual_text_hl_group = "notebook_virtual_text"
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
    insert_blank_line = true,
    show_cell_type = true,
    show_index = true,
    virtual_text_style = { fg = "lightblue", italic = true }
}

return M
