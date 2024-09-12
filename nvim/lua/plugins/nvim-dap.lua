local config = function()
  require("dapui").setup()
  require("nvim-dap-virtual-text").setup({
    commented = true,
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
  }

  -- VSCODE JS (Node/Chrome/Terminal/Jest)
  require("dap-vscode-js").setup({
    -- Path to vscode-js-debug installation.
    debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
    debugger_cmd = { "js-debug-adapter" },
    adapters = { "chrome", "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
  })

  local exts = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
  }

  for i, ext in ipairs(exts) do
    dap.configurations[ext] = {
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
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (pwa-node)",
        cwd = vim.fn.getcwd(),
        args = { "${file}" },
        sourceMaps = true,
        protocol = "inspector",
        runtimeExecutable = "node",
        -- runtimeArgs = {
        --   "run-script",
        --   "dev",
        -- },
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
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Test Current File (pwa-node with deno)",
        cwd = vim.fn.getcwd(),
        runtimeArgs = { "test", "--inspect-brk", "--allow-all", "${file}" },
        runtimeExecutable = "deno",
        attachSimplePort = 9229,
      },
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
  -- -- javascript
  -- dap.adapters["pwa-node"] = {
  --   type = "server",
  --   -- allow from localhost
  --   host = "::1",
  --   --  means nvim-dap will automatically assign a random open port
  --   port = "${port}",
  --   executable = {
  --     -- command = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter", -- Path to VSCode Debugger
  --     command = "js-debug-adapter",
  --     args = { "${port}" },
  --   },
  -- }
  -- dap.configurations["javascript"] = {
  --   {
  --     type = "pwa-node",
  --     request = "launch",
  --     name = "Launch file",
  --     program = "${file}",
  --     cwd = "${workspaceFolder}",
  --   },
  --   {
  --     -- another set of configs here
  --   },
  -- }
  --
  -- for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
  --   require("dap").configurations[language] = {
  --     -- attach to a node process that has been started with
  --     -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
  --     -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
  --     {
  --       -- use nvim-dap-vscode-js's pwa-node debug adapter
  --       type = "pwa-node",
  --       -- attach to an already running node process with --inspect flag
  --       -- default port: 9222
  --       request = "attach",
  --       -- allows us to pick the process using a picker
  --       processId = require("dap.utils").pick_process,
  --       -- name of the debug action you have to select for this config
  --       name = "Attach debugger to existing `node --inspect` process",
  --       -- for compiled languages like TypeScript or Svelte.js
  --       sourceMaps = true,
  --       -- resolve source maps in nested locations while ignoring node_modules
  --       resolveSourceMapLocations = {
  --         "${workspaceFolder}/**",
  --         "!**/node_modules/**",
  --       },
  --       -- path to src in vite based projects (and most other projects as well)
  --       cwd = "${workspaceFolder}/src",
  --       -- we don't want to debug code inside node_modules, so skip it!
  --       skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
  --     },
  --     {
  --       type = "pwa-chrome",
  --       name = "Launch Chrome to debug client",
  --       request = "launch",
  --       url = "http://localhost:5173",
  --       sourceMaps = true,
  --       protocol = "inspector",
  --       port = 9222,
  --       webRoot = "${workspaceFolder}/src",
  --       -- skip files from vite's hmr
  --       skipFiles = { "**/node_modules/**/*", "**/@vite/*", "**/src/client/*", "**/src/*" },
  --     },
  --     -- only if language is javascript, offer this debug action
  --     language == "javascript"
  --         and {
  --           -- use nvim-dap-vscode-js's pwa-node debug adapter
  --           type = "pwa-node",
  --           -- launch a new process to attach the debugger to
  --           request = "launch",
  --           -- name of the debug action you have to select for this config
  --           name = "Launch file in new node process",
  --           -- launch current file
  --           program = "${file}",
  --           cwd = "${workspaceFolder}",
  --         }
  --       or nil,
  --   }
  -- end

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
  },
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    "mxsdev/nvim-dap-vscode-js",
    -- Install the vscode-js-debug adapter
    {
      "microsoft/vscode-js-debug",
      -- After install, build it and rename the dist directory to out
      build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
      version = "1.*",
    },
  },
}
