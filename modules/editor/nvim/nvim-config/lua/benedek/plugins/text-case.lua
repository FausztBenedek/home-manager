return {
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("textcase").setup()
    for _, method in pairs({
      { method_name = "lsp_rename", prefix = "<leader>nr", desc = "with lsp" },
      { method_name = "operator", prefix = "<leader>nv", desc = "with operator" },
    }) do
      --------- OPERATORS ---------
      vim.keymap.set("v", method.prefix .. "u", function()
        require("textcase")[method.method_name]("to_upper_case")
      end, { desc = "Convert to Upper case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "l", function()
        require("textcase")[method.method_name]("to_lower_case")
      end, { desc = "Convert to Lower case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "_", function()
        require("textcase")[method.method_name]("to_snake_case")
      end, { desc = "Convert to snake case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "-", function()
        require("textcase")[method.method_name]("to_dash_case")
      end, { desc = "Convert to Dash case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "C", function()
        require("textcase")[method.method_name]("to_constant_case")
      end, { desc = "Convert to Title Dash case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. ".", function()
        require("textcase")[method.method_name]("to_dot_case")
      end, { desc = "Convert to dot case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. ",", function()
        require("textcase")[method.method_name]("to_comma_case")
      end, { desc = "Convert to comma case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "c", function()
        require("textcase")[method.method_name]("to_camel_case")
      end, { desc = "Convert to Camel case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "p", function()
        require("textcase")[method.method_name]("to_pascal_case")
      end, { desc = "Convert to Pascal case " .. method.desc, noremap = true })

      vim.keymap.set("v", method.prefix .. "/", function()
        require("textcase")[method.method_name]("to_path_case")
      end, { desc = "Convert to Path case " .. method.desc, noremap = true })
    end
  end,
}
