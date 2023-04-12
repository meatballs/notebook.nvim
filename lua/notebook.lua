-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Owen Campbell
-- This software is published at https://github.com/meatballs/notebook.nvim
local M = {}
local ipynb = require("notebook.ipynb")
local render = require("notebook.render")
local api = require("notebook.api")
local settings = require("notebook.settings")

local set_language = function(buffer, content)
    vim.ui.select({ "python", "r", "julia" }, {
        prompt = "Select language:",
    }, function(choice)
        if not content.metadata.kernelspec then
            content.metadata.kernelspec = {}
        end
        content.metadata.kernelspec.language = choice
        render.notebook(buffer, content)
    end
    )
end


M.read_notebook = function(autocmd)
    local buffer = autocmd.buf
    local content = ipynb.load(buffer)

    if not content then
        content = settings.empty_notebook
    end

    vim.api.nvim_buf_create_user_command(
        buffer, "NBAddCell", api.add_cell, {}
    )
    vim.api.nvim_buf_create_user_command(
        buffer, "NBInsertCell", api.insert_cell, {}
    )
    vim.api.nvim_buf_create_user_command(
        buffer, "NBDeleteCell", api.delete_cell, {}
    )
    vim.api.nvim_buf_create_user_command(
        buffer, "NBMoveCell", api.move_cell, { nargs = 1 }
    )
    vim.api.nvim_buf_create_user_command(
        buffer, "NBMoveCellUp", api.move_cell_up, {}
    )
    vim.api.nvim_buf_create_user_command(
        buffer, "NBMoveCellDown", api.move_cell_down, {}
    )
    if content.metadata.kernelspec and content.metadata.kernelspec.language then
        render.notebook(buffer, content)
    else
        set_language(buffer, content)
    end
end

M.write_notebook = function(autocmd)
    local content = ipynb.dump(autocmd.buf)
    local file = io.open(autocmd.file, "w")
    if file then
        file:write(content)
        file:close()
        vim.api.nvim_buf_set_option(autocmd.buf, "modified", false)
    end
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.ipynb" },
    callback = M.read_notebook,
})

vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
    pattern = { "*.ipynb" },
    callback = M.write_notebook,
})

return M
