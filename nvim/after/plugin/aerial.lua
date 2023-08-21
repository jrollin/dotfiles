if not pcall(require, "aerial") then
  return
end
require("aerial").setup({
  backends = { "treesitter", "lsp", "markdown", "man" },
})
