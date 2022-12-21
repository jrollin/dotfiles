local npairs = require("nvim-autopairs")
-- use treesitter
npairs.setup({
    check_ts = true,
})
npairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
