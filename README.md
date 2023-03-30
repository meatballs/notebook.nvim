# notebook.nvim
A [neovim](https://neovim.io) plugin to open `.ipynb` notebook files.

To run notebook cells, you might also want to install the [magma](https://github.com/dccsillag/magma-nvim/) plugin.

## Installation
Install with your favourite plugin manager. e.g.:

### Packer
```lua
use {"meatballs/notebook.nvim"}
```

## Configuration
Add the following to your `init.lua`:

```lua
require('notebook')
```

## Usage
Open an existing `.ipynb` file.

You can add a new cell using `:NBAddCell`

You can then edit the content of any cell and saving the buffer will correctly write your changes back to your notebook file.

## Magma
If you use the [magma](https://github.com/meatballs/magma-nvim) plugin, you can add the following to your neovim config:

```lua
require("notebook")

function _G.define_cell()
    -- Using the current line, define a magma cell from the ipynb cell
    local extmarks = vim.api.nvim_buf_get_var(0, "notebook.extmarks")
    local settings = vim.api.nvim_buf_get_var(0, "notebook.settings")
    local current_line = vim.api.nvim__buf_stats(0).current_lnum

    for id, _ in pairs(extmarks) do
        local extmark = vim.api.nvim_buf_get_extmark_by_id(
            0, settings.plugin_namespace, id, { details = true }
        )
        local start_line = extmark[1] + 1
        local end_line = extmark[3].end_row
        if current_line >= start_line and current_line <= end_line then
            vim.fn.MagmaDefineCell(start_line, end_line)
            break
        end
    end
end

function _G.define_all_cells()
    -- Set magma cells for each cell in the ipynb file
    local extmarks = vim.api.nvim_buf_get_var(0, "notebook.extmarks")
    local settings = vim.api.nvim_buf_get_var(0, "notebook.settings")

    for id, cell in pairs(extmarks) do
        local extmark = vim.api.nvim_buf_get_extmark_by_id(
            0, settings.plugin_namespace, id, { details = true }
        )
        if cell.cell_type == "code" then
            local start_line = extmark[1] + 1
            local end_line = extmark[3].end_row
            vim.fn.MagmaDefineCell(start_line, end_line)
        end
    end

end

-- Init magma when opening an ipynb file
vim.api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    { pattern = { "*.ipynb" }, command = "MagmaInit" }
)
```

NOTE: For these to work, you must use the 'meatballs' fork of the magma plugin as linked above.
