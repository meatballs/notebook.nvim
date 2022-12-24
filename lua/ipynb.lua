-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/ipynb.nvim

local json = require("json")
local render = require("ipynb.render")
local commands = require("ipynb.commands")
local M = {}
local PLUGIN_NAMESPACE = vim.api.nvim_create_namespace("ipynb")
local VIRTUAL_TEXT_NAMESPACE = vim.api.nvim_create_namespace("ipynb.virtual")
local VIRTUAL_TEXT_HL_GROUP = "ipynb_virtual_text"
local VIRTUAL_TEXT_STYLE = { fg = "lightblue", italic = true }

local function parse_ipynb_buffer(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local content = table.concat(lines, "")
    content = content:gsub("\n", "")
    return json.decode(content)
end


M.load_notebook = function(autocmd)
    local buffer = autocmd["buf"]
    local content = parse_ipynb_buffer(buffer)

    vim.api.nvim_buf_set_var(buffer, "notebook", content)
    vim.api.nvim_set_hl(VIRTUAL_TEXT_NAMESPACE, VIRTUAL_TEXT_HL_GROUP, VIRTUAL_TEXT_STYLE)
    vim.api.nvim_set_hl_ns(VIRTUAL_TEXT_NAMESPACE)
    vim.api.nvim_buf_clear_namespace(buffer, PLUGIN_NAMESPACE, 0, -1)
    vim.api.nvim_buf_clear_namespace(buffer, VIRTUAL_TEXT_NAMESPACE, 0, -1)

    local settings = {
        plugin_namespace = PLUGIN_NAMESPACE,
        virt_namespace = VIRTUAL_TEXT_NAMESPACE,
        virt_hl_group = VIRTUAL_TEXT_HL_GROUP
    }
    vim.api.nvim_buf_create_user_command(buffer, "NPAddCell", commands.add_cell, {})
    vim.api.nvim_buf_create_user_command(buffer, "NPInsertCellAbove", commands.insert_cell_above, {})
    vim.api.nvim_buf_create_user_command(buffer, "NPInsertCellBelow", commands.insert_cell_below, {})
    vim.api.nvim_buf_create_user_command(buffer, "NPDeleteCell", commands.delete_cell, {})
    render.notebook(buffer, settings)

end

vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "*.ipynb" },
    callback = M.load_notebook,
})

return M
