if not pcall(require, "gitsigns") then
    return
end
-- git changes annotations
require("gitsigns").setup()
