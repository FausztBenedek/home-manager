local M = {}

M.start_command = function()
  outpub_buffer_nuber = -1
  vim.fn.jobstart({ "./gradlew", "integrationTest", "--tests", "UserChangedOutboxWriterIntegrationTest", "-i" }, {

    stdout_buffered = false,
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(outpub_buffer_nuber, -1, -1, false, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(outpub_buffer_nuber, -1, -1, false, data)
      end
    end,
  })
end

return M
