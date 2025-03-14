local devicons = require("nvim-web-devicons")
local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function find_bookmarks(bookmark_file_path, opts)
  -- 0.75 comes from telescope config
  local total_width = math.floor(0.75 * vim.api.nvim_get_option_value("columns", {})) - 8 -- number is experimented, might be wrong on other computers
  local class_name_width = 60
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 1 },
      { width = class_name_width },
      { width = total_width - class_name_width, right_justify = true }, -- TODO This does not show values accurately, if window is too small
    },
  })
  opts = opts or {}

  -- Read file
  local bookmarks = read_json_file(bookmark_file_path) -- Table to store lines

  -- Create the picker with telescope
  pickers
    .new(opts, {
      prompt_title = bookmark_file_path,
      finder = finders.new_table({
        results = bookmarks,
        entry_maker = function(entry)
          return {
            value = entry.ref,
            display = function()
              local icon, icon_color = devicons.get_icon(entry.name) -- TODO Use color
              return displayer({ { icon, icon_color }, entry.name, entry.ref })
            end,
            ordinal = entry.name,
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
    :find()
end

function find_from_current_bookmar_file()
  find_bookmarks(vim.fn.expand("%"))
end
