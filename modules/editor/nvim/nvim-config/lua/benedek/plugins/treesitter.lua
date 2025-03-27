return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-refactor",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")
    vim.opt.updatetime = 0 -- Allows to highlight variables that are under the cursor immediately

    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- ensure these language parsers are installed
      ensure_installed = {
        -- General
        "json",
        "yaml",
        "xml",
        "toml",
        "markdown",
        "markdown_inline",
        "bash",
        "dockerfile",
        "gitignore",
        -- Webdev
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "scss",
        "svelte",
        "vue",
        "prisma",
        -- Neovim/vim related
        "lua",
        "vim",
        "query",
        "vimdoc",
        -- Other
        "java",
        "python",
        "nix",
        "c",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "Ż",
          node_incremental = "Ż",
          scope_incremental = false,
          node_decremental = "∆",
        },
      },
      refactor = { -- Allows to highlight variables that are under the cursor
        highlight_definitions = {
          enable = true,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = true,
        },
      },
    })
  end,
}
