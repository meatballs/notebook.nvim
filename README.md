# notebook.nvim
A [neovim](https://neovim.io) plugin for working with `.ipynb` notebook files.

## Installation
Install with your favourite plugin manager. e.g.:

### Packer
```lua
use {"meatballs/notebook.nvim"}
```

## Configuration
Add the following to your `init.lua`:

```lua
require('notebook').setup()
```

Or, to set any of the configuration options:

```lua
require('notebook').setup {
    -- Whether to insert a blank line at the top of the notebook
    insert_blank_line = true,

    -- Whether to display the index number of a cell
    show_index = true,

    -- Whether to display the type of a cell
    show_cell_type = true,

    -- Style for the virtual text at the top of a cell
    virtual_text_style = { fg = "lightblue", italic = true },
}
```

## Usage
Open an existing `.ipynb` file or create a new one.

You can then edit the content of any cell and saving the buffer will correctly write your changes back to your notebook file.

### Commands
If you're in a buffer for an .ipynb file, the following commands will be available:

* `NBAddCell` - Add a cell to the end of the notebook
* `NBInsertCell` - Insert a cell below the current cell
* `NBDeleteCell` - Delete the current cell
* `NBMoveCell <index>` - Move the current cell to the given position
* `NBMoveCellDown` - Move the current cell down the notebook by one
* `NBMoveCellUp` - Move the current cell up the notebook by one

> NOTE: There must be no unsaved changes in your buffer before these commands will work and neovim's Undo functionality will not reverse the changes made by these commands.

### Autocommands
The plugin provides User autocommands for your customisation:

* `NBPreRender` - runs immediately before a notebook is rendered
* `NBPostRender` - runs immediately after a notebook is rendered
* `NBPreRenderCell` - runs immediately before each cell is rendered
* `NBPostRenderCell` - runs immediately after each cell is rendered.

## Magma
If you use the [magma](https://github.com/meatballs/magma-nvim) plugin, you can add the following to your neovim config.

This will:

* Prompt for Magma initialisation when an `.ipynb` file is opened
* (Re)define all cells as Magma cells each time the notebook is rendered

```lua
require("notebook")
local api = require("notebook.api")
local settings = require("notebook.settings")

function _G.define_cell(extmark)
    if extmark == nil then
        local line = vim.fn.line(".")
        extmark, _ = api.current_extmark(line)
    end
    local start_line = extmark[1] + 1
    local end_line = extmark[3].end_row
    pcall(function() vim.fn.MagmaDefineCell(start_line, end_line) end)
end

function _G.define_all_cells()
    local buffer = vim.api.nvim_get_current_buf()
    local extmarks = settings.extmarks[buffer]
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
    {pattern = {"MagmaInitPost", "NBPostRender"}, callback = _G.define_all_cells }
)
```

> NOTE: For these to work, you must use the 'meatballs' fork of the magma plugin as linked above.
