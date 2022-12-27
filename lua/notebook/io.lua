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

local get_language = function()
    vim.ui.select({"python", "r", "julia"}, {
        prompt = "Select language:",
    }, function(choice)
        return choice
    end
    )
end

M.parse_ipynb = function(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local content = table.concat(lines, "")
    content = content:gsub("\n", "")
    local parsed_ok, result = pcall(vim.json.decode, content)
    if parsed_ok then
        return result
    else
        local language = get_language()
        local notebook = DEFAULT_NOTEBOOK
        notebook.metadata.language_info.name = language or "python"
        return notebook
    end
end

return M
