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
