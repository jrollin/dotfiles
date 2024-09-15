local config = function()
  require("dapui").setup()
  require("nvim-dap-virtual-text").setup({
    commented = true,
  })
  require("mason-nvim-dap").setup({
    ensure_installed = { "lua", "js", "php" },
    handlers = {},
  })

  local dap, dapui, dap_utils = require("dap"), require("dapui"), require("dap.utils")

  -- php xdebug
  dap.adapters.php = {
    type = "executable",
    command = "node",
    -- when native install without mason
    -- args = { os.getenv("HOME") .. "/vscode-php-debug/out/phpDebug.js" },
    args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
  }
  dap.configurations.php = {
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug",
      port = 9003,
    },
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug docker WS",
      port = 9003,
      pathMappings = {
        ["/var/www/html"] = "${workspaceFolder}",
      },
    },
  }

  -- VSCODE JS (Node/Chrome/Terminal/Jest)
  require("dap-vscode-js").setup({
    -- Path to vscode-js-debug installation.
    -- nvim data : ~/.local/share/nvim/
    debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
    -- debugger_cmd = { "js-debug-adapter" },
    adapters = { "node", "chrome", "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
  })

  local exts = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
  }

  for _, ext in ipairs(exts) do
    dap.configurations[ext] = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (pwa-node)",
        cwd = vim.fn.getcwd(),
        args = { "${file}" },
        sourceMaps = true,
        protocol = "inspector",
        runtimeExecutable = "node",
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },

      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (pwa-node) with Npm",
        cwd = vim.fn.getcwd(),
        args = { "${file}" },
        sourceMaps = true,
        protocol = "inspector",
        runtimeExecutable = "npm",
        runtimeArgs = {
          "run-script",
          "dev",
        },
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (pwa-node with ts-node)",
        cwd = vim.fn.getcwd(),
        runtimeArgs = { "--loader", "ts-node/esm" },
        runtimeExecutable = "node",
        args = { "${file}" },
        sourceMaps = true,
        protocol = "inspector",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Test Current File (pwa-node with jest)",
        cwd = vim.fn.getcwd(),
        runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
        runtimeExecutable = "node",
        args = { "${file}", "--coverage", "false" },
        rootPath = "${workspaceFolder}",
        sourceMaps = true,
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Test Current File (pwa-node with vitest)",
        cwd = vim.fn.getcwd(),
        program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
        args = { "--inspect-brk", "--threads", "false", "run", "${file}" },
        autoAttachChildProcesses = true,
        smartStep = true,
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      -- debug client side
      {
        type = "pwa-chrome",
        request = "launch",
        name = 'Launch Chrome with "localhost" ' .. ext,
        url = function()
          local co = coroutine.running()
          return coroutine.create(function()
            vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:3000" }, function(url)
              if url == nil or url == "" then
                return
              else
                coroutine.resume(co, url)
              end
            end)
          end)
        end,
        port = 9222,
        webRoot = vim.fn.getcwd(),
        protocol = "inspector",
        sourceMaps = true,
        userDataDir = false,
        skipFiles = { "<node_internals>/**", "node_modules/**", "${workspaceFolder}/node_modules/**" },
        resolveSourceMapLocations = {
          "${workspaceFolder}/apps/**/**",
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
      -- Debug nodejs processes (make sure to add --inspect when you run the process)
      {
        type = "pwa-chrome",
        request = "attach",
        name = "Attach Program (pwa-chrome, select port)",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = function()
          return vim.fn.input("Select port: ", 9222)
        end,
        webRoot = "${workspaceFolder}",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach Program (pwa-node, select pid)",
        cwd = vim.fn.getcwd(),
        processId = dap_utils.pick_process,
        skipFiles = { "<node_internals>/**" },
      },
    }
  end

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

return {
  "mfussenegger/nvim-dap",
  config = config,
  keys = {
    {
      "<leader><leader>dt",
      function()
        require("dapui").toggle({})
      end,
      desc = "Dap UI",
    },
    {
      "<leader><leader>de",
      function()
        require("dapui").eval()
      end,
      desc = "Eval",
      mode = { "n", "v" },
    },
    {
      "<leader><leader>dc",
      function()
        require("dap").continue({})
      end,
      desc = "Start debugging",
    },
    {
      "<leader><leader>do",
      function()
        require("dap").step_over({})
      end,
      desc = "Step over",
    },
    {
      "<leader><leader>di",
      function()
        require("dap").step_into({})
      end,
      desc = "Step into",
    },
    {
      "<leader><leader>de",
      function()
        require("dap").step_out({})
      end,
      desc = "Step out",
    },
    {
      "<leader><leader>b",
      function()
        require("dap").set_breakpoint()
      end,
      desc = "Set breakpoint",
    },

    {
      "<leader><leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader><leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Toggle breakpint condition",
    },
    --- Jetbrain like
    -- ---- intellij shortkeys
    -- -- Resume program (F9)
    -- -- Step Over (F8): executing a program one line at a time
    -- -- Step into (F7) : inside the method to demonstrate what gets executed
    -- -- -- Smart step into (Shift + F7)
    -- -- Step out (Shift + F8):  take you to the call method and back up the hierarchy branch of your code
    -- -- -- Run to cursor (Alt + F9)
    -- -- -- Evaluate expression (Alt + F8)
    -- -- Toggle (Ctrl + F8)
    -- -- -- view breakpoints (Ctrl + Shift + F8)
    {
      "<C-F5>",
      function()
        require("dapui").toggle({})
      end,
      desc = "Dap UI",
    },
    {
      "<F7>",
      function()
        require("dap").step_into({})
      end,
      desc = "Step into",
    },
    {
      "<F8>",
      function()
        require("dap").step_over({})
      end,
      desc = "Step over",
    },
    {
      "<F9>",
      function()
        require("dap").continue({})
      end,
      desc = "Start debugging",
    },
    {
      "<S-F8>",
      function()
        require("dap").step_out({})
      end,
      desc = "Step out",
    },
    {
      "<C-F9>",
      function()
        require("dap").toggle_breakpoint({})
      end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader>?",
      function()
        require("dapui").eval(nil, { enter = true })
      end,
      desc = "Eval expression under cursor",
    },
  },
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    -- Install the vscode-js-debug adapter
    "mxsdev/nvim-dap-vscode-js",
    {
      "microsoft/vscode-js-debug",
      -- After install, build it and rename the dist directory to out
      build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
      version = "1.*",
    },
  },
}
