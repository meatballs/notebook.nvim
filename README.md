# notebook.nvim
A [neovim](https://neovim.io) plugin to open `.ipynb` notebook files.

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
Open an existing `.ipynb` file or create a new one.

You can add a new cell using `:NBAddCell`

You can then edit the content of any cell and saving the buffer will correctly write your changes back to your notebook file.

## Magma
If you use the [magma](https://github.com/meatballs/magma-nvim) plugin, you can add the following to your neovim config:

```lua
require("notebook")
local api = require("notebook.api")

function _G.define_cell(extmark)
    if extmark == nil then
        local line = vim.api.nvim__buf_stats(0).current_lnum
        extmark, _ = api.current_extmark(line)
    end
    local start_line = extmark[1] + 1
    local end_line = extmark[3].end_row
    vim.fn.MagmaDefineCell(start_line, end_line)
end

function _G.define_all_cells()
    local extmarks = vim.b.notebook_extmarks
    local settings = vim.b.notebook_settings

    for id, cell in pairs(extmarks) do
        local extmark = vim.api.nvim_buf_get_extmark_by_id(
            0, settings.plugin_namespace, id, { details = true }
        )
        if cell.cell_type == "code" then
            define_cell(extmark)
        end
    end

end

vim.api.nvim_create_autocmd(
    { "BufRead", },
    { pattern = { "*.ipynb" }, command = "MagmaInit" }
)
vim.api.nvim_create_autocmd(
     "User",
    {pattern = "MagmaInitPost", callback = _G.define_all_cells }
)
```

NOTE: For these to work, you must use the 'meatballs' fork of the magma plugin as linked above.
