local devicons = require("nvim-web-devicons")
local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function M.create_find_files_picker(find_command, prompt_title)
  -- 0.75 comes from telescope config
  local totalWidth = math.floor(0.75 * vim.api.nvim_get_option_value("columns", {})) - 8 -- number is experimented, might be wrong on other computers
  local classNameWidth = 60
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 1 },
      { width = classNameWidth },
      { width = totalWidth - classNameWidth, right_justify = true }, -- TODO This does not show values accurately, if window is too small
    },
  })
  local opts = {}

  return pickers.new(opts, {
    prompt_title = prompt_title or "Find files",
    finder = finders.new_oneshot_job(find_command, {
      entry_maker = function(entry)
        local decoded_table = vim.json.decode(entry)
        return {
          value = decoded_table.ref,
          display = function()
            local icon, icon_color = devicons.get_icon(decoded_table.name) -- TODO Use color
            return displayer({ { icon, icon_color }, decoded_table.name, decoded_table.ref })
          end,
          ordinal = decoded_table.name,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd("EditFile " .. selection.value)
      end)
      return true
    end,
  })
end

return M
