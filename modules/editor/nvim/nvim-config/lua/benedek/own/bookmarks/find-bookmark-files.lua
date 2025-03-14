local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function find_bookmark_files(opts)
  opts = opts or {}

  -- Read file
  local handle = io.popen("find vim-data -type f")
  local bookmarks = handle:read("*a")
  handle:close()

  local lines = {}
  for file in string.gmatch(bookmarks, "[^\n]+") do
    table.insert(lines, file)
  end

  -- Create the picker with telescope
  pickers
    .new(opts, {
      prompt_title = "Bookmarks",
      finder = finders.new_table({
        results = lines,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("SpFile " .. selection[1])
        end)
        return true
      end,
    })
    :find()
end

