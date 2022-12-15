if vim.g.loaded_ipynb then
    return
end
vim.g.loaded_ipynb = true

vim.api.nvim_create_autocmd({ "BufRead" }, {
    pattern = { "*.ipynb" },
    callback = require("ipynb").load_notebook,
})
