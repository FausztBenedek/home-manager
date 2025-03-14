function save_qf_list(target_file)
  local qflist = vim.fn.getqflist()
  file = io.open(target_file, "w")
  file:write("[\n")
  for _, list_entry in pairs(qflist) do
    local bufnr = list_entry["bufnr"]
    local row = '{"name": "' .. list_entry["text"] .. '", "ref": "' .. vim.api.nvim_buf_get_name(bufnr) .. '"},\n'
    file:write(row)
  end
  file:write("]")
  file:close()
end

function load_qf_list(from_bookmarks_json)
  local bookmarks = read_json_file(from_bookmarks_json)
  local qf_items = {}
  for _, bookmark in pairs(bookmarks) do
    local f = string.gmatch(bookmark.ref, "[^:]+")
    table.insert(qf_items, { filename = f() })
  end
  vim.fn.setqflist(qf_items)
end
