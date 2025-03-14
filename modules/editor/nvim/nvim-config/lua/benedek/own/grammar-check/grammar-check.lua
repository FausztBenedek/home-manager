local M = {}

local function run_command_with_vim_loop(args)
  local uv = vim.loop
  local handle
  handle, pid = uv.spawn(
    args.cmd,
    {
      args = args.args,
      stdio = { nil, stdout, stderr },
    },
    vim.schedule_wrap(function()
      handle:close()
    end)
  )
  uv.run("once")
  print("AI started with pid=" .. pid)
  return pid
end

local function create_temp_file()
  local temp_file = vim.fn.tempname()
  vim.cmd("split " .. temp_file)
  return temp_file
end

local function cleanup_on_buffer_close(buffer, pid)
  -- Define an autocommand group
  vim.api.nvim_create_augroup("GrammarCheckingCloserAuGroup", { clear = true })

  -- Create an autocommand for when a buffer is closed
  vim.api.nvim_create_autocmd("BufDelete", {
    group = "GrammarCheckingCloserAuGroup",
    buffer = buffer,
    callback = function()
      local command = "pkill -P " .. pid
      os.execute(command)
    end,
  })
end

-- Main function to handle the plugin logic
function M.show_info()
  local input
  if vim.fn.visualmode() ~= "" then
    -- Get visually selected text
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    input = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
    input = table.concat(input, "\n")
  else
    -- Get entire buffer content
    input = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    input = table.concat(input, "\n")
  end

  local temp_file_path = create_temp_file()
  local pid = run_command_with_vim_loop({
    cmd = "_ask-grammar-check-from-nvim",
    args = { temp_file_path, '"' .. input .. '"' },
  })
  os.execute("sleep " .. tonumber(0.1))
  vim.cmd("term tail -f " .. temp_file_path)
  -- Get the buffer number of the terminal buffer
  local bufnr = vim.fn.bufnr("%")
  -- Set the buffer to readonly
  vim.api.nvim_buf_set_option(bufnr, "readonly", true)

  --TODO Delete tempfile and stop process
  cleanup_on_buffer_close(bufnr, pid)
end

return M
