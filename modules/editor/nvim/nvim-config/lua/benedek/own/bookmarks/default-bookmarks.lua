local Path = require("plenary.path")
local bookmark_file = "vim-data/default.bookmarks.json"

function set_default_bookmark()
  local current_file_path = vim.fn.expand("%")
  local current_line = vim.fn.line(".")
  local file_name = vim.fn.fnamemodify(current_file_path, ":t")
  --local row = '{"name": "' .. file_name .. '", "ref": "' .. current_file_path .. "#" .. current_line .. '"},\n'
  local path = Path:new(bookmark_file)
  local current_json = {}
  if path:exists() then
    current_json = read_json_file(bookmark_file)
  end

  current_json[#current_json + 1] = {
    name = file_name,
    ref = current_file_path .. ":" .. current_line,
  }
  path:touch({ parents = true })
  write_json_file(bookmark_file, current_json)
end

function find_default_bookmark()
  find_bookmarks(bookmark_file)
end
