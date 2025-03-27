return {
  "tpope/vim-fugitive",
  config = function()
    vim.api.nvim_set_keymap(
      "n",
      "<leader>gb",
      ":<C-U>Git blame<CR>",
      { noremap = true, desc = "Open git blame", silent = true }
    )

    -- Show commits for repository
    vim.keymap.set("n", "<leader>gH", function()
      vim.cmd("Git log --decorate --oneline --graph")
    end, { noremap = true, desc = "Show commits for repository", silent = true })

    -- Show commits that changed the file in buffer
    vim.keymap.set("n", "<leader>gh", function()
      vim.cmd("Git log --decorate --oneline --graph %")
    end, { noremap = true, desc = "Show commits that changed the file in buffer", silent = true })

    -- Compare file to its previous state in the commit in the clipboard
    vim.keymap.set("n", "<leader>gd", function()
      local commit_hash = vim.fn.getreg('"')
      vim.cmd("Gvdiffsplit " .. commit_hash)
    end, {
      noremap = true,
      desc = "Compare file to its previous state in the commit in the clipboard",
      silent = true,
    })

    -- Fold a diff to show only files
    -- Define an autocommand group
    --vim.api.nvim_create_augroup("FoldGitDiffAutomatically", { clear = true })
    ---- Create an autocommand for when a buffer is closed
    --vim.api.nvim_create_autocmd("BufEnter", {
    --  group = "FoldGitDiffAutomatically",
    --  pattern = "git",
    --  callback = function()
    --    print("Hello")
    --    vim.opt_local.foldmethod = "syntax"
    --  end,
    --})
    vim.keymap.set("n", "<leader>gf", function()
      vim.opt_local.foldmethod = "syntax"
    end, { noremap = true, desc = 'Diff with commit hash in the " register', silent = true })
  end,
}
