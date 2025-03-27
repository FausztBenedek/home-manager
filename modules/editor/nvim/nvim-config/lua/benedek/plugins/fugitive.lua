return {
  "tpope/vim-fugitive",
  config = function()
    vim.api.nvim_set_keymap(
      "n",
      "<leader>gb",
      ":<C-U>Git blame<CR>",
      { noremap = true, desc = "Open git blame", silent = true }
    )

    vim.keymap.set("n", "<leader>gh", function()
      vim.cmd("Git log --decorate --oneline --graph %")
    end, { noremap = true, desc = "Show commits that changed the file", silent = true })

    vim.keymap.set("n", "<leader>gH", function()
      vim.cmd("Git log --decorate --oneline --graph")
    end, { noremap = true, desc = "Show commits", silent = true })

    vim.keymap.set("n", "<leader>gd", function()
      local commit_hash = vim.fn.getreg('"')
      vim.cmd("Gvdiffsplit " .. commit_hash)
    end, { noremap = true, desc = "Diff with commit hash in the \" register", silent = true })
  end,
}
