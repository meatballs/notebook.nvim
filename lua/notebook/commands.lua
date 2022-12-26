-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local M = {}
local render = require("notebook.render")

local function add_cell(line, cell_type)
    local cell = {cell_type=cell_type, source={""}}
    render.cell(0, line, cell)
    vim.api.nvim_win_set_cursor(0, {line + 1, 0})
end


M.add_cell = function()
    local buffer_length = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    add_cell(buffer_length)
end

M.insert_cell= function(command)
    local cell_type = command.fargs[1] or "code"
    vim.notify("Not implemented yet. Cell type: " .. cell_type, vim.log.levels.WARN)
end

M.delete_cell = function(command)
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

M.execute_cell = function(command)
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

return M
