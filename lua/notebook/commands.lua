-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local M = {}
local render = require("notebook.render")



local function add_cell(line, cell_type)
    local cell = { cell_type = cell_type, source = { "" } }
    local settings = vim.api.nvim_buf_get_var(0, "notebook.settings")
    local content = vim.api.nvim_buf_get_var(0, "notebook.content")
    local language = content.metadata.language_info.name
    render.cell(0, line, cell, settings, language)
    vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
end

local set_cell_type = function(line)
    vim.ui.select({"code", "markdown", "raw"}, {
        prompt = "Select cell type:",
    }, function(choice)
        add_cell(line, choice)
    end
    )
end

M.add_cell = function(command)
    local cell_type = command.fargs[1]
    local last_line = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if cell_type then
        add_cell(last_line, cell_type)
    else
        set_cell_type(last_line)
    end
end

M.insert_cell = function(command)
    local cell_type = command.fargs[1] or "code"
    vim.notify("Not implemented yet. Cell type: " .. cell_type, vim.log.levels.WARN)
end

M.delete_cell = function(command)
    vim.notify("Not implemented yet", vim.log.levels.WARN)
end

return M
