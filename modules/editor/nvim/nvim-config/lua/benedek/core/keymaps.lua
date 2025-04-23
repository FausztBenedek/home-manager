vim.g.mapleader = " "

-- Temporarily disable, so that I get used to CAPS_LOCK
vim.api.nvim_set_keymap("i", "<C-c>", "", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-c>", "", { noremap = true, silent = true })

-- Navigation commands
vim.api.nvim_set_keymap("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-c>", ":noh<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-q>", ":<c-u>q<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-n>", ":<c-u>tabn<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-p>", ":<c-u>tabp<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ú", "]", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "ő", "[", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "-", "/", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "<C-w><C-h>", "<C-w>H", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w><C-j>", "<C-w>J", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w><C-k>", "<C-w>K", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w><C-l>", "<C-w>L", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-h>", "2<C-w><", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-j>", "2<C-w>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-k>", "2<C-w>-", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-S-l>", "2<C-w>>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>sphu", ":<c-u>set spell spelllang=hu<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>spen", ":<c-u>set spell spelllang=en<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>spde", ":<c-u>set spell spelllang=de<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>spde", ":<c-u>set spell spelllang=de<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  "n",
  "<leader>aicg",
  ':lua require("benedek.own.grammar-check.grammar-check").show_info()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>aicg",
  ':<C-U>lua require("benedek.own.grammar-check.grammar-check").show_info()<CR>',
  { noremap = true, silent = true }
)

-- Commands to copy filename
vim.keymap.set("n", ",cc", function()
  vim.fn.setreg("*", vim.fn.expand("%"))
end, { noremap = true, silent = true, desc = "Copy current file's path relative to the project root" })

vim.keymap.set("n", ",cp", function()
  vim.fn.setreg("*", vim.fn.expand("%:p"))
end, { noremap = true, silent = true, desc = "Copy current file's full path" })

vim.keymap.set("n", ",cn", function()
  vim.fn.setreg("*", vim.fn.expand("%:t"))
end, { noremap = true, silent = true, desc = "Copy current file's name" })

vim.keymap.set("n", "<leader>vo", function()
  local file_path = vim.fn.expand("%:p")
  local line_number = vim.fn.line(".")
  local command =
    string.format("/Applications/IntelliJ\\ IDEA.app/Contents/MacOS/idea --line %d %s", line_number, file_path)
  print(command)
  vim.fn.system(command)
end, { noremap = true, silent = true, desc = "Opens the current file in Intellij" })

vim.cmd("source $HM/vim/common-keymaps.vim")
