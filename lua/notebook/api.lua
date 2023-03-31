-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim
local M = {}
local render = require("notebook.render")
local settings = require("notebook.settings")


M.current_extmark = function(line)
    local buffer = vim.api.nvim_get_current_buf()
    if not line then
        line = vim.api.nvim__buf_stats(0).current_lnum
    end
    local extmarks = settings.extmarks[buffer]
    for id, _ in pairs(extmarks) do
        local extmark = vim.api.nvim_buf_get_extmark_by_id(
            0, settings.plugin_namespace, id, { details = true }
        )
        local start_line = extmark[1] + 1
        local end_line = extmark[3].end_row
        if line >= start_line and line <= end_line then
            return extmark, id
        end
    end
end

local function add_cell(cell, line)
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.b.notebook.content
    local idx
    if not line then
        table.insert(content.cells, cell)
    else
        _, idx = M.current_extmark(line)
        table.insert(content.cells, idx + 1, cell)
    end
    render.notebook(buffer, content)
end

local set_cell_type = function(line)
    vim.ui.select({ "code", "markdown", "raw" }, {
        prompt = "Select cell type:",
    }, function(choice)
        local cell = { cell_type = choice, source = { "" } }
        add_cell(cell, line)
    end
    )
end

M.add_cell = function(command)
    if vim.o.modified then
        vim.notify(
            "There are unsaved changes. Save your notebook before adding cells",
            vim.log.levels.WARN
        )
        return
    end
    local cell_type = command.fargs[1]
    if cell_type then
        local cell = { cell_type = cell_type, source = { "" } }
        add_cell(cell)
    else
        set_cell_type()
    end
end

M.insert_cell = function(command)
    if vim.o.modified then
        vim.notify(
            "There are unsaved changes. Save your notebook before adding cells",
            vim.log.levels.WARN
        )
        return
    end
    local cell_type = command.fargs[1]
    local line = vim.api.nvim__buf_stats(0).current_lnum
    if cell_type then
        local cell = { cell_type = cell_type, source = { "" } }
        add_cell(cell, line)
    else
        set_cell_type(line)
    end
end

M.delete_cell = function(command)
    if vim.o.modified then
        vim.notify(
            "There are unsaved changes. Save your notebook before deleting cells",
            vim.log.levels.WARN
        )
        return
    end
    local buffer = vim.api.nvim_get_current_buf()
    local _, idx = M.current_extmark()
    local content = vim.b.notebook.content
    table.remove(content.cells, idx)
    render.notebook(buffer, content)
end

return M
