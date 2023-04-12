-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim
local M = {}
local settings = require("notebook.settings")


local function add_virtual_text(buffer, idx, line, cell, language)
    local cell_type = cell.cell_type
    if cell_type == "code" then cell_type = language end
    local text = "[" .. idx .. "][" .. cell_type .. "]"
    local virt_opts = {
        virt_lines = { { { "" } }, { { text, settings.virtual_text_hl_group } } },
        virt_lines_above = true,
    }
    vim.api.nvim_buf_set_extmark(
        buffer, settings.virtual_text_namespace, line, 0, virt_opts
    )
end

local function add_extmark(buffer, line, end_line)
    local opts = { end_line = end_line }
    return vim.api.nvim_buf_set_extmark(
        buffer, settings.plugin_namespace, line, 0, opts
    )
end

M.cell = function(buffer, idx, line, cell, language)
    local source = {}
    local source_start_line = line
    local source_end_line
    local end_line

    for k, v in ipairs(cell.source) do
        source[k] = v:gsub("\n", "")
    end
    source_end_line = line + #source
    end_line = source_end_line

    if cell.cell_type == "markdown" then
        local markers = settings.comment_markers[language]
        table.insert(source, 1, markers["start"] .. "---")
        table.insert(source, markers["finish"])
        source_start_line = source_start_line + 1
        source_end_line = source_end_line + 1
        end_line = end_line + 2
    end

    if #source == 0 then
        table.insert(source, 1, "")
    end

    vim.api.nvim_buf_set_lines(buffer, line, line, false, source)
    add_virtual_text(buffer, idx, line, cell, language)
    local extmark = add_extmark(buffer, source_start_line, source_end_line)
    settings.extmarks[buffer][extmark] = cell
end

M.notebook = function(buffer, content)
    -- This seems to break if we use a vim buffer variable, so we'll use settings
    -- instead
    settings.extmarks[buffer] = {}
    settings.plugin_namespace = vim.api.nvim_create_namespace("")
    vim.api.nvim_set_hl(
        settings.virtual_text_namespace,
        settings.virtual_text_hl_group,
        settings.virtual_text_style
    )
    vim.api.nvim_set_hl_ns(settings.virtual_text_namespace)

    vim.api.nvim_buf_clear_namespace(buffer, settings.virtual_text_namespace, 0, -1)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
    local language = content.metadata.kernelspec.language

    local line = 0
    for idx, cell in ipairs(content.cells) do
        cell.outputs = nil
        M.cell(buffer, idx, line, cell, language)
        line = line + #cell.source
        if cell.cell_type == "markdown" then line = line + 2 end
    end

    -- Use a vim buffer variable so it gets cleared when the buffer is deleted
    vim.b.notebook = { content = content }
    vim.api.nvim_buf_set_option(buffer, "filetype", language)
    vim.cmd({ cmd = "doautocmd", args = { "User", "NBPostRender" } })
end

return M
