local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- set root dir even if not git
    {
        "notjedi/nvim-rooter.lua",
        config = function()
            require("nvim-rooter").setup({ rooter_patterns = { ".git", "package.json", "cargo.toml", "Makefile" } })
        end,
    },
    -- file explorer
    "nvim-tree/nvim-tree.lua",
    --  color ui
    "gruvbox-community/gruvbox",
    "folke/lsp-colors.nvim",
    "norcalli/nvim-colorizer.lua",

    -- dev icon
    { "nvim-tree/nvim-web-devicons", lazy = true },
    -- status line
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "arkav/lualine-lsp-progress",
        dependencies = { "nvim-lualine/lualine.nvim" },
    },
    -- LSP
    {
        -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
    },
    -- diagnostic
    {
        "folke/trouble.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
    },
    -- autocomplete and snippets
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            -- snippets
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
            -- format cmp sugestion
            "onsails/lspkind-nvim",
        },
    },
    "stevearc/aerial.nvim",
    -- UI stuff (mainly used for lsp overrides)
    "RishabhRD/popfix",
    "RishabhRD/nvim-lsputils",

    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "windwp/nvim-ts-autotag",
            "p00f/nvim-ts-rainbow",
            "JoosepAlviste/nvim-ts-context-commentstring",
            -- Additional text objects via treesitter
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
    },
    "nvim-treesitter/playground",
    -- idk
    "jose-elias-alvarez/null-ls.nvim",
    "MunifTanjim/prettier.nvim",
    -- format code

    "kylechui/nvim-surround",

    "numToStr/Comment.nvim",
    "editorconfig/editorconfig-vim",
    "windwp/nvim-autopairs",
    -- telescope
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    "nvim-telescope/telescope-fzy-native.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-media-files.nvim",
    {
        "nvim-telescope/telescope-ui-select.nvim", -- Use telescope to override vim.ui.select
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    -- git
    { "lewis6991/gitsigns.nvim",     dependencies = { "nvim-lua/plenary.nvim" } },
    "tpope/vim-fugitive",
    -- lang
    -- rust
    "simrat39/rust-tools.nvim",
    {
        "saecki/crates.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("crates").setup()
        end,
    },
    -- go
    "golang/vscode-go",
    -- js
    "xabikos/vscode-javascript",
    -- yaml and config files
    "tpope/vim-markdown",
    "cespare/vim-toml",
    "stephpy/vim-yaml",
    "hashivim/vim-terraform",
    -- vim-markdown
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    -- Debugging (needs plenary from above as well)
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
})
