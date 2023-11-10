local aug = vim.api.nvim_create_augroup("JR", { clear = true })
local myfunc = function()
  local data = {
    buffer = vim.fn.expand("<abuf>"),
    filename = vim.fn.expand("<afile>"),
  }
  vim.schedule(function()
    vim.api.nvim_command('echo "Hello, Nvim!"')
    print(vim.inspect(data))
  end)
end
vim.api.nvim_create_autocmd("BufEnter", { callback = myfunc, group = aug, pattern = "*.md" })
