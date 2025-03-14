vim.keymap.set("n", "<leader>bf", find_bookmark_files, { desc = "Navigate to bookmark files", noremap = true })
vim.keymap.set("n", "<leader>ba", set_default_bookmark, { desc = "Set bookmark on current line", noremap = true })
vim.keymap.set("n", "<leader>bs", find_default_bookmark, { desc = "Find bookmarks on current line", noremap = true })

vim.keymap.set(
  "n",
  "<leader>bc",
  find_from_current_bookmar_file,
  { desc = "finds files based on current bookmark file", noremap = true }
)
