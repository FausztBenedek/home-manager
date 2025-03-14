local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.create_run_config_picker()
  local opts = {}
  return pickers
    .new(opts, {
      prompt_title = "Run script",
      finder = finders.new_oneshot_job({ "find", "vim-data/run-configs", "-type", "f" }, {
        entry_maker = function(entry)
          return {
            value = entry,
            display = function()
              local script_name = string.gsub(entry, "^vim.data/run.configs/", "")
              return script_name
            end,
            ordinal = entry,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.api.nvim_exec2("!" .. selection.value, {})
        end)
        return true
      end,
    })
    :find()
end

return M
