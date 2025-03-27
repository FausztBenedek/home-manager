vim.g.mapleader = " "

vim.api.nvim_set_keymap("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-c>", ":noh<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-q>", ":<c-u>q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-q>", ":<c-u>tabc<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-l>", ":<c-u>tabn<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-h>", ":<c-u>tabp<cr>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>sphu", ":<c-u>set spell spelllang=hu<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>spen", ":<c-u>set spell spelllang=en<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>spde", ":<c-u>set spell spelllang=de<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>spde", ":<c-u>set spell spelllang=de<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>aicg', ':lua require("benedek.own.grammar-check.grammar-check").show_info()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>aicg', ':<C-U>lua require("benedek.own.grammar-check.grammar-check").show_info()<CR>', { noremap = true, silent = true })

vim.cmd("source $HM/vim/common-keymaps.vim")
