local json = require("json")
local M = {}

local function parse_ipynb_buffer(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local content = table.concat(lines, "")
	content = content:gsub("\n", "")
	return json.decode(content)
end

local function render_virtual_text(buffer, line, idx, cell, language, namespace)
	local cell_type = cell["cell_type"]
	if cell_type == "code" then cell_type = language end
    local virt_text = "[#" .. idx .. "] " .. cell_type
	local virt_opts = {
		virt_lines = { { { "" } }, { { virt_text, "ipynb_virt" } } },
		virt_lines_above = true,
	}
	vim.api.nvim_buf_set_extmark(buffer, namespace, line, 0, virt_opts)
end

M.render_cell = function(buffer, line, idx, cell, language, namespace)
	local source = {}
	for k, v in ipairs(cell["source"]) do
		source[k] = v:gsub("\n", "")
	end
	local end_line = line + #source

	vim.api.nvim_buf_set_lines(buffer, line, end_line, false, source)
    render_virtual_text(buffer, line, idx, cell, language, namespace)

    return end_line
end

M.render_notebook = function(buffer, namespace)
    local notebook = vim.api.nvim_buf_get_var(buffer, "notebook")
    local language = notebook["metadata"]["language_info"]["name"]

	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})

	local line = 0
	for idx, cell in ipairs(notebook["cells"]) do
		line = M.render_cell(buffer, line, idx, cell, language, namespace)
	end

	vim.api.nvim_buf_set_option(0, "filetype", "notebook")
end

M.load_notebook = function(autocmd)
    local buffer = autocmd["buf"]
	local namespace = vim.api.nvim_create_namespace("ipynb")
    local content = parse_ipynb_buffer(buffer)

    vim.api.nvim_buf_set_var(buffer, "notebook", content)
	vim.api.nvim_set_hl(namespace, "ipynb_virt", { fg = "lightblue", italic = true })
	vim.api.nvim_set_hl_ns(namespace)
	vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)

    M.render_notebook(buffer, namespace)

end

vim.api.nvim_create_autocmd({ "BufRead" }, {
	pattern = { "*.ipynb" },
	callback = M.load_notebook,
})

return M
