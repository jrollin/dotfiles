local config = function()
    require("dapui").setup()
    require("nvim-dap-virtual-text").setup({
        commented = true,
    })
    local dap, dapui = require("dap"), require("dapui")

    -- php xdebug
    -- git clone https://github.com/xdebug/vscode-php-debug.git && \
    -- cd vscode-php-debug && \
    -- npm install && npm run build
    dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { os.getenv("HOME") .. "/vscode-php-debug/out/phpDebug.js" },
    }
    dap.configurations.php = {
        {
            type = "php",
            request = "launch",
            name = "Listen for Xdebug",
            port = 9003,
        },
    }

    dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter", -- Path to VSCode Debugger
            args = { "${port}" },
        },
    }

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
            "<leader><leader>db",
            function()
                require("dap").toggle_breakpoint({})
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
    },
}
