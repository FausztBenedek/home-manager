-- Docs: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Java related stuff
    "mfussenegger/nvim-jdtls", -- Configuration in nvim-config/ftplugin/java.lua
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local configurationFunctions = require("benedek.plugins.lsp.lsp-configs.configs")
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    for i = 1, #configurationFunctions do
      configurationFunctions[i]({ capabilities = capabilities })
    end
    vim.lsp.inlay_hint.enable(true)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          float = {
            border = "rounded",
            source = true,
          },
          severity_sort = true,
        })
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "LSP incoming_calls to quickfixlist"
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts) -- show definition, references

        opts.desc = "Show LSP definitions"
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definitions

        opts.desc = "Show LSP incoming_calls in quickfixlist"
        vim.keymap.set("n", "gi", vim.lsp.buf.incoming_calls, opts) -- show lsp implementations

        opts.desc = "Show LSP incoming_calls with Telescope"
        vim.keymap.set("n", "gI", "<cmd>Telescope lsp_incoming_calls<cr>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Toggle inlay hint"
        vim.keymap.set({ "n", "v" }, "<leader>ch", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "<leader>ci", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

        opts.desc = "Code actions"
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Remove test files and import from references quickfixlist"
        vim.keymap.set("n", "<leader>cr", function()
          vim.cmd("g/import /d")
          vim.cmd("g/.spec.ts/d")
          vim.cmd("g/.spec.tsx/d")
        end, {
          desc = "Remove test files and import from references quickfixlist",
          noremap = true,
          silent = true,
        })
      end,
    })

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
  end,
}
