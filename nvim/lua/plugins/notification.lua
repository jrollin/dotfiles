local config = function()
  require("fidget").setup()
end

return {
  "j-hui/fidget.nvim",
  lazy = false,
  config = config,
}
