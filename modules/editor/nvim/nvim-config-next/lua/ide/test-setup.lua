vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/nvim-neotest/neotest-python" },
	-- Other dependencies that are installed elsewhere
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
}, { confirm = false })

require("neotest").setup({
	adapters = {
		require("neotest-python")({}),
	},
})

vim.keymap.set("n", "<leader>tr", function()
	require("neotest").run.run()
end, {noremap = true, silent = true})
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.open()
end, {noremap = true, silent = true})
