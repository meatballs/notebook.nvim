-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim
local M = {}
local settings = require("notebook.settings")

M.load = function(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local content = table.concat(lines, "")
    local parsed_ok, result = pcall(vim.json.decode, content)
    if parsed_ok then
        return result
    else
        return settings.empty_notebook
    end
end

M.dump = function(buffer)
    local content = vim.b.notebook.content
    local extmarks = settings.extmarks[buffer]
    local default_cell_metadata = { collapsed = false }

    local cells = {}
    for id, cell in pairs(extmarks) do
        if cell.metadata == nil or #cell.metadata == 0 then
            cell.metadata = default_cell_metadata
        end
        cell.outputs = {}
        local extmark = vim.api.nvim_buf_get_extmark_by_id(
            buffer, settings.plugin_namespace, id, { details = true }
        )
        local end_row = extmark[3].end_row
        local source = vim.api.nvim_buf_get_lines(buffer, extmark[1], end_row, true)
        if #source > 0 then
            for idx, v in pairs(source) do
                source[idx] = v .. "\n"
            end
            cell.source = source
            table.insert(cells, cell)
        end
    end

    local ipynb = content
    ipynb.cells = cells
    return vim.json.encode(ipynb)
end

return M
