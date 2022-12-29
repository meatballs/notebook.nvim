-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local M = {}

local function add_virtual_text(buffer, line, cell)
    local settings = vim.api.nvim_buf_get_var(buffer, "notebook.settings")
    local cell_type = cell.cell_type
    if cell_type == "code" then cell_type = settings.language end
    local virt_opts = {
        virt_lines = { { { "" } }, { { cell_type, settings.virt_hl_group } } },
        virt_lines_above = true,
    }
    vim.api.nvim_buf_set_extmark(buffer, settings.virt_namespace, line, 0, virt_opts)
end

local function add_extmark(buffer, line, end_line, settings)
    local opts = { end_line = end_line }
    return vim.api.nvim_buf_set_extmark(buffer, settings.plugin_namespace, line, 0, opts)
end

M.cell = function(buffer, line, cell)
    local settings = vim.api.nvim_buf_get_var(buffer, "notebook.settings")
    local source = {}
    for k, v in ipairs(cell.source) do
        source[k] = v:gsub("\n", "")
    end
    local end_line = line + #source

    vim.api.nvim_buf_set_lines(buffer, line, end_line, false, source)
    add_virtual_text(buffer, line, cell)
    return add_extmark(buffer, line, end_line, settings)
end

M.notebook = function(buffer, content, settings)
    local extmarks = {}

    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
    vim.api.nvim_buf_set_var(buffer, "notebook.settings", settings)
    vim.api.nvim_buf_set_var(buffer, "notebook.content", content)

    local line = 0
    for _, cell in ipairs(content.cells) do
        local extmark = M.cell(buffer, line, cell)
        extmarks[extmark] = cell
        line = line + #cell.source
    end

    vim.api.nvim_buf_set_var(buffer, "notebook.extmarks", extmarks)
    vim.api.nvim_buf_set_option(0, "filetype", "notebook")
end

return M
