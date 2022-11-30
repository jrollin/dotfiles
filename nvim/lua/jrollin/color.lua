require 'colorizer'.setup()

local custom_gruvbox = require 'lualine.themes.gruvbox_dark'
-- Change the background of lualine_c section for normal mode
-- custom_gruvbox.normal.c.bg = '#112233'
require('lualine').setup {
    options = { theme = custom_gruvbox },
    extensions = { 'nvim-tree', 'fugitive', 'nvim-dap-ui'},
    sections = {
        -- add progress status extension to left 
        lualine_c = {
            'filename',
            'lsp_progress'
        }
    }
}
