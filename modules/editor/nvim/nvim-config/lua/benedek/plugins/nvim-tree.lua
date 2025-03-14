return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        adaptive_size = true,
        relativenumber = true,
      },
      -- change folder arrow icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },

      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { ".DS_Store" },
      },
      git = {
        ignore = false,
      },
      on_attach = function(bufnr)
        -- I copied this function from https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt
        local api = require("nvim-tree.api")

        -- use all default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- remove a default to be able to close immediately after opening it
        vim.keymap.del("n", "<C-e>", { buffer = bufnr })
      end,
    })

    vim.keymap.set("n", "<leader>11", "<cmd>NvimTreeFocus<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
    vim.keymap.set("n", "<leader>1t", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
    vim.keymap.set("n", "<C-e><C-e>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
    vim.keymap.set("n", "<C-e><C-f>", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Open on current file" }) -- toggle file explorer on current file
    vim.keymap.set("n", "<leader>1c", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
    vim.keymap.set("n", "<leader>1r", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
  end,
}
