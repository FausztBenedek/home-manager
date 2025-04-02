return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio", -- Dependency of nvim-dap-ui
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -------- KEYMAPS --------
    vim.keymap.set("n", "<F5>", function()
      dap.continue()
    end)
    vim.keymap.set("n", "<F10>", function()
      dap.step_into()
    end)
    vim.keymap.set("n", "<F11>", function()
      dap.step_over()
    end)
    vim.keymap.set("n", "<F12>", function()
      dap.step_out()
    end)
    vim.keymap.set("n", "<Leader>b", function()
      dap.toggle_breakpoint()
    end)
    vim.keymap.set("n", "<Leader>B", function()
      dap.set_breakpoint()
    end)
    vim.keymap.set("n", "<Leader>lp", function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end)
    vim.keymap.set("n", "<Leader>dr", function()
      dap.repl.open()
    end)
    vim.keymap.set("n", "<Leader>dl", function()
      dap.run_last()
    end)
    vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
      require("dap.ui.widgets").hover()
    end)
    vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
      require("dap.ui.widgets").preview()
    end)
    vim.keymap.set("n", "<Leader>df", function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.frames)
    end)
    vim.keymap.set("n", "<Leader>ds", function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.scopes)
    end)

    --------- ADAPTERS ---------
    -- See https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
    dap.adapters.python = function(cb, config)
      if config.request == "attach" then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or "127.0.0.1"
        cb({
          type = "server",
          port = assert(port, "`connect.port` is required for a python `attach` configuration"),
          host = host,
          options = {
            source_filetype = "python",
          },
        })
      else
        cb({
          type = "executable",
          command = "/Users/benedekfauszt/.nix-profile/bin/python",
          args = { "-m", "debugpy.adapter" },
          options = {
            source_filetype = "python",
          },
        })
      end
    end

    --------- CONFIGURATIONS ---------
    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = "launch",
        name = "Launch file",

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

        program = "${file}", -- This configuration will launch the current file if used.
        pythonPath = function()
          -- -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
          -- -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
          -- -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
          -- local cwd = vim.fn.getcwd()
          -- if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          --   return cwd .. "/venv/bin/python"
          -- elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          --   return cwd .. "/.venv/bin/python"
          -- else
          --   return "/usr/bin/python"
          -- end
          return "/Users/benedekfauszt/.nix-profile/bin/python";
        end,
      },
    }
  end,
}
