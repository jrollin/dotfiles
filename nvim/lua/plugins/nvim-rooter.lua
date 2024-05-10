-- auto-cd to root of git project
return {
  "notjedi/nvim-rooter.lua",
  config = function()
    require("nvim-rooter").setup()
  end,
}
