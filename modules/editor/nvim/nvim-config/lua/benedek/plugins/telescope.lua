local telescope_helper = require("benedek.own.telescope-helper.file-selector")
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        layout_config = {
          width = 0.75, -- Adjust this value to set the width
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files with relative path to cwd", noremap = true })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files", noremap = true })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd", noremap = true })
    vim.keymap.set("n", "<leader>fs", function()
      local node = require("nvim-tree.api").tree.get_node_under_cursor()
      if node and node.type == "directory" then
        builtin.live_grep({ search_dirs = { node.absolute_path }, prompt_title = "Live grep in " .. node.absolute_path })
      else
        builtin.live_grep()
      end
    end, { desc = "Find string in cwd", noremap = true })
    vim.keymap.set("n", "<leader>fF", function()
      local node = require("nvim-tree.api").tree.get_node_under_cursor()
      if node and node.type == "directory" then
        telescope_helper
          .create_find_files_picker({ "find-files-in-nvim", node.absolute_path }, "Find files in " .. node.absolute_path)
          :find()
      else
        telescope_helper.create_find_files_picker({ "find-files-in-nvim" }):find()
      end
    end, { desc = "Search for files in anywhere or in directory if selected", noremap = true }) -- refresh file explorer
  end,
}
