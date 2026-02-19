local orig_vtext_show = vim.diagnostic.handlers.virtual_text.show
local orig_vtext_hide = vim.diagnostic.handlers.virtual_text.hide

vim.diagnostic.handlers.virtual_text.show = function(namespace, bufnr, diagnostics, opts)
  if vim.bo[bufnr].filetype == "markdown" and vim.b[bufnr].md_vtext_hidden ~= false then
    return
  end
  return orig_vtext_show(namespace, bufnr, diagnostics, opts)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.b[args.buf].md_vtext_hidden = true

    vim.keymap.set("n", "<leader>dv", function()
      local bufnr = args.buf
      local hidden = vim.b[bufnr].md_vtext_hidden
      vim.b[bufnr].md_vtext_hidden = not hidden
      local opts = vim.diagnostic.config()
      for ns_id, _ in pairs(vim.diagnostic.get_namespaces()) do
        if hidden then
          local diags = vim.diagnostic.get(bufnr, { namespace = ns_id })
          orig_vtext_show(ns_id, bufnr, diags, opts)
        else
          orig_vtext_hide(ns_id, bufnr)
        end
      end
    end, { buffer = args.buf, desc = "Toggle [D]iagnostic [V]irtual text" })
  end,
})

return {

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- For `nvim-treesitter` users.
    priority = 49,
    opts = {},
    config = function()
      local presets = require("markview.presets")
      local glow = presets.headings.glow
      -- override
      glow.shift_width = 0

      require("markview").setup({
        preview = {
          filetypes = { "markdown", "codecompanion", "avante" },
          ignore_buftypes = {},
        },
        markdown = {
          headings = glow,
          code_blocks = {
            enable = false,
          },
        },
      })
    end,
  },
}
