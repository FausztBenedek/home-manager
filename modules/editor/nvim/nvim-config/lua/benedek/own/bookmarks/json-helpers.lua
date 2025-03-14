local Path = require("plenary.path")

-- Function to read JSON file
function read_json_file(file_path)
  local path = Path:new(file_path)
  local content = path:read()
  return vim.fn.json_decode(content)
end

function write_json_file(file_path, json)
  local path = Path:new(file_path)
  path:write(vim.fn.json_encode(json), "w")
end
