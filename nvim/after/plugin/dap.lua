if not pcall(require, "dapui") then
    return
end

if not pcall(require, "nvim-dap-virtual-text") then
    return
end

require("dapui").setup()
require("nvim-dap-virtual-text").setup({
    commented = true,
})
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
