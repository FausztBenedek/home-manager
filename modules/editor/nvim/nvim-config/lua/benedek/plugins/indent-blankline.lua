return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  config = function()
    local highlight = {
      "Indent1",
      "Indent2",
      "Indent3",
    }

    local hooks = require("ibl.hooks")
    -- create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "Indent1", { fg = "#51AFED" })
      vim.api.nvim_set_hl(0, "Indent2", { fg = "#3EB1BB" })
      vim.api.nvim_set_hl(0, "Indent3", { fg = "#3EBBA5" })
    end)

    require("ibl").setup({
      indent = {
        char = "┊",
        highlight = highlight,
      },
    })
  end,
}
