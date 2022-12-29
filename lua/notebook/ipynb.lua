-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local M = {}
local DEFAULT_NOTEBOOK = {
    cells = {},
    metadata = {
        language_info = {
            name = ""
        },
        nbformat = 4,
        nbformat_minor = 5,
    }
}

M.load = function(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local content = table.concat(lines, "")
    content = content:gsub("\n", "")
    local parsed_ok, result = pcall(vim.json.decode, content)
    if parsed_ok then
        return result
    else
        return DEFAULT_NOTEBOOK
    end
end

M.dump = function(buffer)
    local content = vim.api.nvim_buf_get_var(buffer, "notebook.content")
    local extmarks = vim.api.nvim_buf_get_var(buffer, "notebook.extmarks")
    local default_cell_metadata = { collapsed = false }
    local ipynb = {
        metadata = content.metadata,
        nbformat = content.nbformat,
        nbformat_minor = content.nbformat_minor,
        cells = {
            {
                cell_type = "markdown",
                metadata = default_cell_metadata,
                source = { "## Hello World" },
            },
            {
                cell_type = "code",
                metadata = default_cell_metadata,
                source = { "test = [1,2,3]"}
            }
        },
    }
    return vim.json.encode(ipynb)
end

return M
