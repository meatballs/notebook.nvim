-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local io = require("notebook.io")
local render = require("notebook.render")
local commands = require("notebook.commands")
local M = {}
local PLUGIN_NAMESPACE = vim.api.nvim_create_namespace("notebook")
local VIRTUAL_TEXT_NAMESPACE = vim.api.nvim_create_namespace("notebook.virtual")
local VIRTUAL_TEXT_HL_GROUP = "notebook_virtual_text"
local VIRTUAL_TEXT_STYLE = { fg = "lightblue", italic = true }

local set_language = function(buffer, content, settings)
    vim.ui.select({ "python", "r", "julia" }, {
        prompt = "Select language:",
    }, function(choice)
        settings.language = choice
        vim.api.nvim_buf_set_var(buffer, "notebook.content", content)
        render.notebook(buffer, settings)
    end
    )
end

M.load_notebook = function(autocmd)
    local buffer = autocmd["buf"]
    local content = io.parse_ipynb(buffer)

    vim.api.nvim_set_hl(VIRTUAL_TEXT_NAMESPACE, VIRTUAL_TEXT_HL_GROUP, VIRTUAL_TEXT_STYLE)
    vim.api.nvim_set_hl_ns(VIRTUAL_TEXT_NAMESPACE)
    vim.api.nvim_buf_clear_namespace(buffer, PLUGIN_NAMESPACE, 0, -1)
    vim.api.nvim_buf_clear_namespace(buffer, VIRTUAL_TEXT_NAMESPACE, 0, -1)

    local settings = {
        plugin_namespace = PLUGIN_NAMESPACE,
        virt_namespace = VIRTUAL_TEXT_NAMESPACE,
        virt_hl_group = VIRTUAL_TEXT_HL_GROUP
    }
    vim.api.nvim_buf_create_user_command(buffer, "NBAddCell", commands.add_cell, {})
    vim.api.nvim_buf_create_user_command(buffer, "NBInsertCell", commands.insert_cell, { nargs = "?" })
    vim.api.nvim_buf_create_user_command(buffer, "NBDeleteCell", commands.delete_cell, { nargs = "?" })
    if content.metadata.language_info.name then
        settings.language = content.metadata.language_info.name
        vim.api.nvim_buf_set_var(buffer, "notebook.content", content)
        render.notebook(buffer, settings)
    else
        set_language()
    end

end

M.save_notebook = function(autocmd)
    vim.notify("Not Implemented Yet", vim.log.levels.WARN)
end

vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "*.ipynb" },
    callback = M.load_notebook,
})

vim.api.nvim_create_autocmd({ "BufWrite" }, {
    pattern = { "*.ipynb" },
    callback = M.save_notebook,
})

return M
