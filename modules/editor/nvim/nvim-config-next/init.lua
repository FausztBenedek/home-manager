-- To build nvim:
--
-- (the nix shell command does not work for some reason?)
-- nix-shell -p cmake gettext libtool automake ninja
-- make CMAKE_BUILD_TYPE=RelWithDebInfo  CMAKE_C_COMPILER=/opt/homebrew/opt/llvm/bin/clang  CMAKE_CXX_COMPILER=clang++=/opt/homebrew/opt/llvm/bin/clang++
-- sudo make install
--
-- And then to run it:
--
-- XDG_CONFIG_HOME=$(pwd)/config XDG_DATA_HOME=$(pwd)/data build/bin/nvim

------ OPTIONS ------
vim.g.mapleader = ' '

-- TODO Delete
-- vim.keymap.set('n', '<leader>r', ':<c-u>restart<cr>', { noremap = false, silent = true })
-- TODO End delete block
-- line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent-- Create an autocommand group

vim.opt.wrap = false
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
vim.opt.swapfile = false

-- Highlight the current line where the cursor is currently
vim.opt.cursorline = true
vim.cmd('colorscheme darkblue')
vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register


------ CORE KEYMAPS ------
vim.keymap.set('n', '<Esc>', ':<c-u>nohlsearch<CR>', { noremap = true, silent = true }) -- Disables highlight
vim.keymap.set('n', '<C-q>', ':<c-u>q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-b>', ':<c-u>bd<CR>', { noremap = true, silent = true })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>", { noremap = false, silent = true })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:<c-u>q!<cr>", { noremap = false, silent = true })
vim.keymap.set("t", "<C-b>", "<C-\\><C-n>:<c-u>bd!<cr>", { noremap = false, silent = true })
vim.keymap.set("n", "<C-t>", ":<c-u>25 sp | term<cr>i", { noremap = false, silent = true })

vim.keymap.set('n', '<C-n>', ':<c-u>tabn<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', ':<c-u>tabp<cr>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-w><C-h>', '<C-w>H', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w><C-j>', '<C-w>J', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w><C-k>', '<C-w>K', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w><C-l>', '<C-w>L', { noremap = true, silent = true })

vim.keymap.set('n', '<C-S-h>', '2<C-w><', { noremap = true, silent = true })
vim.keymap.set('n', '<C-S-j>', '2<C-w>+', { noremap = true, silent = true })
vim.keymap.set('n', '<C-S-k>', '2<C-w>-', { noremap = true, silent = true })
vim.keymap.set('n', '<C-S-l>', '2<C-w>>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })

vim.keymap.set('n', '<C-.>', 'mJA;<esc>`J', { noremap = true, silent = true })
vim.keymap.set('n', '<C-,>', 'mJA,<esc>`J', { noremap = true, silent = true })
vim.keymap.set('i', '<C-.>', '<esc>mJA;<esc>`J', { noremap = true, silent = true })
vim.keymap.set('i', '<C-,>', '<esc>mJA,<esc>`J', { noremap = true, silent = true })

-- English keyboard similarity maps
vim.api.nvim_set_keymap('n', 'ú', ']', { noremap = false, silent = true }) -- must remain nvim_set_keymap, other does not work
vim.api.nvim_set_keymap('n', 'ő', '[', { noremap = false, silent = true })
vim.keymap.set('n', '-', '/', { noremap = false, silent = true })
vim.keymap.set('n', '<C-y>', ':<c-u>normal! <cr>', { noremap = false, silent = true }) -- <C-a> (the original increment) is mapped on the system level to enter the tiling windon manager mode

------ PLUGINS ------
vim.pack.add({
  -- Plugins that are just added (no setup function needed)
  { src = 'https://github.com/itchyny/vim-qfedit' },
  { src = 'https://github.com/tpope/vim-surround' },
  { src = 'https://github.com/folke/which-key.nvim' },

  -- Plugins needing configuration (at least a setup function)
  { src = 'https://github.com/chiedo/vim-case-convert' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
  { src = 'https://github.com/nvim-mini/mini.pick' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
}, { confirm = false })

-- https://github.com/chiedo/vim-case-convert
vim.keymap.set(
  'v',
  ',vc-',
  ':CamelToHyphen<CR>a',
  { noremap = false, silent = true, desc = 'CamelToDash' }
)
vim.keymap.set(
  'v',
  ',vc_',
  ':CamelToSnake<CR>a',
  { noremap = false, silent = true, desc = 'CamelToSnake' }
)
vim.keymap.set(
  'v',
  ',v-c',
  ':HyphenToCamel<CR>a',
  { noremap = false, silent = true, desc = 'DashToCamel' }
)
vim.keymap.set(
  'v',
  ',v-_',
  ':HyphenToSnake<CR>a',
  { noremap = false, silent = true, desc = 'DashToSnake' }
)
vim.keymap.set(
  'v',
  ',v_c',
  ':SnakeToCamel<CR>a',
  { noremap = false, silent = true, desc = 'SnakeToCamel' }
)
vim.keymap.set(
  'v',
  ',v_-',
  ':SnakeToHyphen<CR>a',
  { noremap = false, silent = true, desc = 'SnakeToDash' }
)

-- https://github.com/lukas-reineke/indent-blankline.nvim
local hooks = require('ibl.hooks')
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  -- create the highlight groups in the highlight setup hook, so they are reset
  -- every time the colorscheme changes
  vim.api.nvim_set_hl(0, 'Indent1', { fg = '#51AFED' })
  vim.api.nvim_set_hl(0, 'Indent2', { fg = '#3EB1BB' })
  vim.api.nvim_set_hl(0, 'Indent3', { fg = '#3EBBA5' })
end)
require('ibl').setup({
  indent = {
    char = '┊',
    highlight = {
      'Indent1',
      'Indent2',
      'Indent3',
    },
  },
})

-- https://github.com/nvim-mini/mini.pick
require('mini.pick').setup({
  window = {
    config = function()
      local height = math.floor(0.9 * vim.o.lines)
      local width = math.floor(0.9 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  },
})
vim.keymap.set('n', '<leader>ff', function()
  MiniPick.builtin.files({ tool = 'git' })
end, { noremap = false, silent = true, desc = 'CamelToDash' })
vim.keymap.set('n', '<leader>fb', function()
  MiniPick.builtin.buffers()
end, { noremap = false, silent = true, desc = 'CamelToDash' })
vim.keymap.set('n', '<leader>fs', function()
  MiniPick.builtin.grep({ tool = 'git' })
end, { noremap = false, silent = true, desc = 'CamelToDash' })

-- https://github.com/nvim-treesitter/nvim-treesitter
local treesitter_languages = {
  -- General
  'json',
  'yaml',
  'xml',
  'toml',
  'markdown',
  'markdown_inline',
  'bash',
  'dockerfile',
  'gitignore',
  -- Webdev
  'javascript',
  'typescript',
  'tsx',
  'html',
  'css',
  'scss',
  'svelte',
  'vue',
  'prisma',
  'astro',
  -- Neovim/vim related
  'lua',
  'vim',
  'query',
  'vimdoc',
  -- Other
  'java',
  'python',
  'rust',
  'nix',
}
require('nvim-treesitter').install(treesitter_languages)
vim.api.nvim_create_autocmd('FileType', {
  pattern = treesitter_languages,
  callback = function()
    vim.treesitter.start()
  end,
})

-- https://github.com/stevearc/oil.nvim
require("oil").setup({
  keymaps = {
      ["<C-v>"] = { "actions.select", opts = { vertical = true } },
      ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-h>"] = false,
      ["<C-l>"] = false,
    },

})
vim.keymap.set("n", "<c-e><c-e>", ":<c-u>Oil ".. vim.fn.getcwd() .."<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<c-e><c-f>", ":<c-u>Oil<cr>", { noremap = true, silent = true })

-- https://github.com/windwp/nvim-autopairs
require('nvim-autopairs').setup({})

require('hacky.incremental-selection')
require('ide.lsp-setup')
require('ide.git-setup')
require('ide.formatter-setup')

