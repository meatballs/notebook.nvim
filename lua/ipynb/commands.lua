local M = {}
local render = require("ipynb.render")

local function add_cell(line, cell_type)
    local cell = {cell_type=cell_type, source={""}}
    local idx = 22
    render.cell(0, line, idx, cell)
    vim.api.nvim_win_set_cursor(0, {line + 1, 0})
end


M.add_cell = function()
    local buffer_length = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    add_cell(buffer_length)
end

M.insert_cell= function(command)
    local cell_type = command.fargs[1] or "code"
    add_cell(4, cell_type)
end

M.delete_cell = function(command)
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

return M
