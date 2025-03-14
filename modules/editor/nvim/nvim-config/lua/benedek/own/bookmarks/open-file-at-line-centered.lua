-- Function to open a file, jump to a specific line, and center it on the screen
function open_file_at_line_centered(cmd, file_expr)
  local file_and_line_number_iter = string.gmatch(file_expr, "([^:]+)")
  local file = file_and_line_number_iter()
  local line = file_and_line_number_iter()
  if line == nil then
    vim.api.nvim_command(cmd .. " " .. file)
  else
    vim.api.nvim_command(cmd .. " +" .. line .. " " .. file)
  end
  vim.api.nvim_command("normal! zz")
end

for _, command in pairs({ "edit", "vs", "sp", "tabe" }) do
  local new_command = string.gsub(command, "^.", string.upper) .. "File"

  -- Create a custom Vim command
  vim.api.nvim_create_user_command(new_command, function(opts)
    open_file_at_line_centered(command, opts.fargs[1])
  end, { nargs = 1 })
end
