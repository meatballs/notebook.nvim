-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local M = {}
local render = require("notebook.render")



local function add_cell(cell)
    local last_line = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local settings = vim.api.nvim_buf_get_var(0, "notebook.settings")
    local content = vim.api.nvim_buf_get_var(0, "notebook.content")
    local extmarks = vim.api.nvim_buf_get_var(0, "notebook.extmarks")
    local language = content.metadata.language_info.name
    local extmark = render.cell(0, last_line, cell, settings, language)
    extmarks[extmark] = cell
    vim.api.nvim_win_set_cursor(0, { last_line + 1, 0 })
    vim.api.nvim_buf_set_var(0, "notebook.extmarks", extmarks)
end

local set_cell_type = function(line)
    vim.ui.select({"code", "markdown", "raw"}, {
        prompt = "Select cell type:",
    }, function(choice)
        local cell = { cell_type = choice, source = { "" } }
        add_cell(cell)
    end
    )
end

M.add_cell = function(command)
    local cell_type = command.fargs[1]
    if cell_type then
        local cell = { cell_type = cell_type, source = { "" } }
        add_cell(cell)
    else
        set_cell_type()
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
