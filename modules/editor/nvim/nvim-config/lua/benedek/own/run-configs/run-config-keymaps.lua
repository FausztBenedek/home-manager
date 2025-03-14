local run_configs = require("benedek.own.run-configs.run-configs")

vim.keymap.set(
  "n",
  "<leader>rr",
  run_configs.create_run_config_picker,
  { desc = "Run stuff from vim-data/run-configs", noremap = true }
)
