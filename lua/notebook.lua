-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim

local ipynb = require("notebook.ipynb")
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
        render.notebook(buffer, content, settings)
    end
    )
end

M.read_notebook = function(autocmd)
    local buffer = autocmd["buf"]
    local content = ipynb.load(buffer)

    vim.api.nvim_set_hl(VIRTUAL_TEXT_NAMESPACE, VIRTUAL_TEXT_HL_GROUP, VIRTUAL_TEXT_STYLE)
    vim.api.nvim_set_hl_ns(VIRTUAL_TEXT_NAMESPACE)
    vim.api.nvim_buf_clear_namespace(buffer, PLUGIN_NAMESPACE, 0, -1)
    vim.api.nvim_buf_clear_namespace(buffer, VIRTUAL_TEXT_NAMESPACE, 0, -1)

    local settings = {
        plugin_namespace = PLUGIN_NAMESPACE,
        virt_namespace = VIRTUAL_TEXT_NAMESPACE,
        virt_hl_group = VIRTUAL_TEXT_HL_GROUP
    }
    vim.api.nvim_buf_create_user_command(buffer, "NBAddCell", commands.add_cell, {nargs = "?"})
    vim.api.nvim_buf_create_user_command(buffer, "NBInsertCell", commands.insert_cell, { nargs = "?" })
    vim.api.nvim_buf_create_user_command(buffer, "NBDeleteCell", commands.delete_cell, { nargs = "?" })
    if #content.metadata.language_info.name > 0 then
        settings.language = content.metadata.language_info.name
        render.notebook(buffer, content, settings)
    else
        set_language(buffer, content, settings)
    end

end

M.write_notebook = function(autocmd)
    local content = ipynb.dump(autocmd.buf)
    local file = io.open(autocmd.file, "w")
    file:write(content)
    io.close()

end

vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "*.ipynb" },
    callback = M.read_notebook,
})

vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
    pattern = { "*.ipynb" },
    callback = M.write_notebook,
})

return M
