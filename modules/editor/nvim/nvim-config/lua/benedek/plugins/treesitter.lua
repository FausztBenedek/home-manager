return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

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
    })
  end,
}
