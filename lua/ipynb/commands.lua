local M = {}
local render = require("ipynb.render")

local function add_cell(line)
    local cell = {cell_type="code", source={""}}
    render.cell(0, line, 22, cell)
end


M.add_cell = function()
    local buffer_length = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    add_cell(buffer_length)
    vim.api.nvim_win_set_cursor(0, {buffer_length + 1, 0})
end

M.insert_cell_above = function()
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

M.insert_cell_below = function()
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

M.delete_cell = function()
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

return M
