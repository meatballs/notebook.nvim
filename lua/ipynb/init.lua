-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2022 Owen Campbell
--
-- This software is published at https://github.com/meatballs/ipynb.nvim

local json = require("json")
local M = {}
local PLUGIN_NAMESPACE = vim.api.nvim_create_namespace("ipynb")
local VIRTUAL_TEXT_HL_GROUP = "ipynb_virtual_text"
local VIRTUAL_TEXT_STYLE = { fg = "lightblue", italic = true}

local function parse_ipynb_buffer(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local content = table.concat(lines, "")
	content = content:gsub("\n", "")
	return json.decode(content)
end

local function set_cell_extmark(buffer, line, end_line, idx, cell, language)
	local cell_type = cell["cell_type"]
	if cell_type == "code" then cell_type = language end
    local virt_text = "[#" .. idx .. "] " .. cell_type
	local virt_opts = {
        end_row = end_line,
		virt_lines = { { { "" } }, { { virt_text, VIRTUAL_TEXT_HL_GROUP } } },
		virt_lines_above = true,
	}
	return vim.api.nvim_buf_set_extmark(buffer, PLUGIN_NAMESPACE, line, 0, virt_opts)
end

M.render_cell = function(buffer, line, idx, cell, language)
	local source = {}
	for k, v in ipairs(cell["source"]) do
		source[k] = v:gsub("\n", "")
	end
	local end_line = line + #source

	vim.api.nvim_buf_set_lines(buffer, line, end_line, false, source)
    local extmark_id = set_cell_extmark(buffer, line, end_line, idx, cell, language)
    local mapping = vim.api.nvim_buf_get_var(buffer, "cell_2_extmark")
    mapping[cell["id"]] = extmark_id
    vim.api.nvim_buf_set_var(buffer, "cell_2_extmark", mapping)

    return end_line
end

M.render_notebook = function(buffer)
    local notebook = vim.api.nvim_buf_get_var(buffer, "notebook")
    local language = notebook["metadata"]["language_info"]["name"]

	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
    vim.api.nvim_buf_set_var(buffer, "cell_2_extmark", {})

	local line = 0
	for idx, cell in ipairs(notebook["cells"]) do
		line = M.render_cell(buffer, line, idx, cell, language)
	end

	vim.api.nvim_buf_set_option(0, "filetype", "notebook")
end

M.load_notebook = function(autocmd)
    local buffer = autocmd["buf"]
    local content = parse_ipynb_buffer(buffer)

    vim.api.nvim_buf_set_var(buffer, "notebook", content)
	vim.api.nvim_set_hl(PLUGIN_NAMESPACE, VIRTUAL_TEXT_HL_GROUP, VIRTUAL_TEXT_STYLE)
	vim.api.nvim_set_hl_ns(PLUGIN_NAMESPACE)
	vim.api.nvim_buf_clear_namespace(buffer, PLUGIN_NAMESPACE, 0, -1)

    M.render_notebook(buffer)

end

vim.api.nvim_create_autocmd({ "BufRead" }, {
	pattern = { "*.ipynb" },
	callback = M.load_notebook,
})

return M
