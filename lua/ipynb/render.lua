-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/ipynb.nvim

local M = {}

local function set_cell_extmark(buffer, line, end_line, idx, cell, settings)
    local cell_type = cell["cell_type"]
    if cell_type == "code" then cell_type = settings["language"] end
    local virt_text = "[#" .. idx .. "] " .. cell_type
    local virt_opts = {
        end_row = end_line,
        virt_lines = { { { "" } }, { { virt_text, settings["hl_group"] } } },
        virt_lines_above = true,
    }
    return vim.api.nvim_buf_set_extmark(buffer, settings["namespace"], line, 0, virt_opts)
end

M.cell = function(buffer, line, idx, cell, settings)
    local source = {}
    for k, v in ipairs(cell["source"]) do
        source[k] = v:gsub("\n", "")
    end
    local end_line = line + #source

    vim.api.nvim_buf_set_lines(buffer, line, end_line, false, source)
    local extmark_id = set_cell_extmark(buffer, line, end_line, idx, cell, settings)
    local mapping = vim.api.nvim_buf_get_var(buffer, "cell_2_extmark")
    mapping[cell["id"]] = extmark_id
    vim.api.nvim_buf_set_var(buffer, "cell_2_extmark", mapping)

    return end_line
end

M.notebook = function(buffer, settings)
    local notebook = vim.api.nvim_buf_get_var(buffer, "notebook")
    settings["language"] = notebook["metadata"]["language_info"]["name"]

    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
    vim.api.nvim_buf_set_var(buffer, "cell_2_extmark", {})

    local line = 0
    for idx, cell in ipairs(notebook["cells"]) do
        line = M.cell(buffer, line, idx, cell, settings)
    end

    vim.api.nvim_buf_set_option(0, "filetype", "notebook")
end

return M
