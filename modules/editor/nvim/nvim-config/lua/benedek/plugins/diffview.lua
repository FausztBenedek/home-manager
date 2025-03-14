return {
  "sindrets/diffview.nvim",
  config = function()
    vim.api.nvim_set_keymap("n", "<leader>df", ":DiffviewOpen<cr>", { noremap = false, silent = true })
  end,
}
