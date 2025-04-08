return {
  "j-morano/buffer_manager.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local buffer_manager_ui = require("buffer_manager.ui")

    vim.keymap.set(
      { "t", "n" },
      "<leader>bb",
      buffer_manager_ui.toggle_quick_menu,
      { noremap = true, desc = "Toggle the buffer menu" }
    )
    -- Open menu and search
    vim.keymap.set({ "t", "n" }, "<leader>bm", function()
      buffer_manager_ui.toggle_quick_menu()
      -- wait for the menu to open
      vim.defer_fn(function()
        vim.fn.feedkeys("/")
      end, 50)
    end, { noremap = true, desc = "Toggle and search in buffer menu" })
    -- Next/Prev
    vim.keymap.set("n", "<leader>bn", buffer_manager_ui.nav_next, { noremap = true, desc = "Next buffer" })
    vim.keymap.set("n", "<leader>bp", buffer_manager_ui.nav_prev, { noremap = true, desc = "Previous buffer" })
    -- Move buffer up / down one line
    vim.api.nvim_command([[
      autocmd FileType buffer_manager vnoremap J :m '>+1<CR>gv=gv
      autocmd FileType buffer_manager vnoremap K :m '<-2<CR>gv=gv
    ]])
    vim.keymap.set("n", "<leader>bw", "<cmd>bd<cr>", { noremap = true, desc = "Delete current buffer" })
  end,
}
