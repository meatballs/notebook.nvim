-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim
local M = {}
local render = require("notebook.render")
local settings = require("notebook.settings")

local function get_extmark_for_cell(idx)
    local buffer = vim.api.nvim_get_current_buf()
    local extmarks = vim.api.nvim_buf_get_extmarks(
        buffer, settings.plugin_namespace, 0, -1, {}
    )
    local extmark_id = extmarks[idx][1]
    local extmark = vim.api.nvim_buf_get_extmark_by_id(
        buffer, settings.plugin_namespace, extmark_id, { details = true }
    )
    return extmark
end

local function set_cursor_to_cell(idx)
    local extmark = get_extmark_for_cell(idx)
    local end_of_cell = extmark[3].end_row
    local last_line = vim.api.nvim_buf_line_count(0)
    if end_of_cell == 0 then end_of_cell = last_line end
    local line = math.min(end_of_cell, last_line)
    vim.api.nvim_win_set_cursor(0, { line, 0 })
end

local function has_unsaved_changes(operation)
    local result = vim.o.modified
    if result then
        vim.notify(
            "There are unsaved changes. Save your notebook before " ..
            operation .. " cells",
            vim.log.levels.WARN
        )
    end
    return result
end

local function exclude_markers(line, language)
    local result = line
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.api.nvim_buf_get_lines(buffer, line - 1, line, false)[1]
    if content == settings.comment_markers[language].start .. "---" then
        result = line + 1
    end
    if content == settings.comment_markers[language].finish then result = line - 1 end
    return result
end

M.current_extmark = function()
    local buffer = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim__buf_stats(0).current_lnum
    local content = vim.b.notebook.content
    local language = content.metadata.kernelspec.language
    line = exclude_markers(line, language)
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

local function add_new_cell(idx, cell_type)
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.b.notebook.content
    local cell = { cell_type = cell_type, source = { "" } }
    table.insert(content.cells, idx + 1, cell)
    render.notebook(buffer, content)
    set_cursor_to_cell(idx + 1)
end

local function set_cell_type(idx)
    vim.ui.select({ "code", "markdown", "raw" }, {
        prompt = "Select cell type:",
    }, function(choice)
        add_new_cell(idx, choice)
    end
    )
end

M.add_cell = function(command)
    if has_unsaved_changes("adding") then return end
    local content = vim.b.notebook.content
    local idx = #content.cells
    set_cell_type(idx)
end

M.insert_cell = function(command)
    if has_unsaved_changes("adding") then return end
    local extmark, idx = M.current_extmark()
    if not extmark then
        vim.notify(
            "Cannot determine current cell.",
            vim.log.levels.WARN
        )
        return
    end
    set_cell_type(idx)
end

M.delete_cell = function(command)
    if has_unsaved_changes("deleting") then return end
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.b.notebook.content
    local extmark, idx = M.current_extmark()
    if not extmark then
        vim.notify(
            "Cannot determine current cell.",
            vim.log.levels.WARN
        )
        return
    end
    table.remove(content.cells, idx)
    render.notebook(buffer, content)
end

M.move_cell = function(command)
    if has_unsaved_changes("moving") then return end
    local to = tonumber(command.fargs[1])
    if to < 1 then
        vim.notify("Cell is already the first in the notebook.", vim.log.levels.WARN)
        return
    end
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.b.notebook.content
    if to > #content.cells then
        vim.notify("Cell is already the last in the notebook.", vim.log.levels.WARN)
        return
    end
    local extmark, idx = M.current_extmark()
    if not extmark then
        vim.notify(
            "Cannot determine current cell.",
            vim.log.levels.WARN
        )
        return
    end
    local cell = table.remove(content.cells, idx)
    table.insert(content.cells, to, cell)
    render.notebook(buffer, content)
end

M.move_cell_up = function(command)
    if has_unsaved_changes("moving") then return end
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.b.notebook.content
    local extmark, idx = M.current_extmark()
    if not extmark then
        vim.notify(
            "Cannot determine current cell.",
            vim.log.levels.WARN
        )
        return
    end
    local to = idx - 1
    if to < 1 then
        vim.notify("Cell is already the first in the notebook.", vim.log.levels.WARN)
        return
    end
    local cell = table.remove(content.cells, idx)
    table.insert(content.cells, to, cell)
    render.notebook(buffer, content)
end

M.move_cell_down = function(command)
    if has_unsaved_changes("moving") then return end
    local buffer = vim.api.nvim_get_current_buf()
    local content = vim.b.notebook.content
    local extmark, idx = M.current_extmark()
    if not extmark then
        vim.notify(
            "Cannot determine current cell.",
            vim.log.levels.WARN
        )
        return
    end
    local to = idx + 1
    if to > #content.cells then
        vim.notify("Cell is already the last in the notebook.", vim.log.levels.WARN)
        return
    end
    local cell = table.remove(content.cells, idx)
    table.insert(content.cells, to, cell)
    render.notebook(buffer, content)
end

return M
