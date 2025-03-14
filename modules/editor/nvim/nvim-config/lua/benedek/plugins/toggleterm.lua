return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({})

    vim.api.nvim_set_keymap("n", "<C-t>", ":ToggleTerm<CR>", { noremap = false, silent = true })
    vim.api.nvim_set_keymap("t", "<C-t>", "<C-\\><C-n>", { noremap = false, silent = true })
  end,
}
