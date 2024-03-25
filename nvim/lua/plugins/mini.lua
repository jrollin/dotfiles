local config = function()
  require("mini.ai").setup()
  require("mini.surround").setup()
end
return {
  "echasnovski/mini.nvim",
  lazy = false,
  config = config,
}
