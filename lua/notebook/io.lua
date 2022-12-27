-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local M = {}
local DEFAULT_NOTEBOOK = {
    cells = {},
    metadata = {
        language_info = {
            name = "python"
        },
        nbformat = 4,
        nbformat_minor = 5,
    }
}

M.parse_ipynb = function(buffer)
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

return M
