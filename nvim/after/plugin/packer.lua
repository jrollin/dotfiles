-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")
    -- file explorer
    use("kyazdani42/nvim-tree.lua")
    --  color ui
    use("gruvbox-community/gruvbox")
    use("folke/lsp-colors.nvim")
    use("p00f/nvim-ts-rainbow")
    use("norcalli/nvim-colorizer.lua")

    -- dev icon
    use("kyazdani42/nvim-web-devicons")
    -- status line
    use({
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
    })
    use({
        "arkav/lualine-lsp-progress",
        requires = { "nvim-lualine/lualine.nvim" },
    })
    -- LSP
    use({ -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        requires = {
            -- Automatically install LSPs to stdpath for neovim
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
    })
    -- autocomplete and snippets
    use({
        "hrsh7th/nvim-cmp",
        requires = {
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
    })

    use({
        "stevearc/aerial.nvim",
        config = function()
            require("aerial").setup()
        end,
    })
    -- UI stuff (mainly used for lsp overrides)
    use("RishabhRD/popfix")
    use("RishabhRD/nvim-lsputils")

    -- treesitter
    use("nvim-treesitter/nvim-treesitter", {
        run = function()
            pcall(require("nvim-treesitter.install").update({ with_sync = true }))
        end,
    })
    use({ -- Additional text objects via treesitter
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
    })
    use("JoosepAlviste/nvim-ts-context-commentstring")
    -- idk
    use("jose-elias-alvarez/null-ls.nvim")
    -- format code
    use("tpope/vim-surround")
    use("tpope/vim-commentary")
    use("editorconfig/editorconfig-vim")
    use("windwp/nvim-autopairs")
    use("windwp/nvim-ts-autotag")
    -- telescope
    use("nvim-lua/popup.nvim")
    use("nvim-lua/plenary.nvim")
    use({ "nvim-telescope/telescope.nvim", tag = "0.1.0", requires = { { "nvim-lua/plenary.nvim" } } })
    use("nvim-telescope/telescope-fzy-native.nvim")
    use("nvim-telescope/telescope-file-browser.nvim")
    use("nvim-telescope/telescope-media-files.nvim")
    -- git
    use({ "lewis6991/gitsigns.nvim", requires = { { "nvim-lua/plenary.nvim" } } })
    use("tpope/vim-fugitive")
    -- lang
    -- rust
    use("simrat39/rust-tools.nvim")
    -- go
    use("golang/vscode-go")
    -- js
    use("xabikos/vscode-javascript")
    -- yaml and config files
    use("tpope/vim-markdown")
    use("cespare/vim-toml")
    use("stephpy/vim-yaml")
    use("hashivim/vim-terraform")
    -- vim-markdown
    use("ellisonleao/glow.nvim")
    use({
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
    })

    -- Debugging (needs plenary from above as well)
    use("mfussenegger/nvim-dap")
    use("rcarriga/nvim-dap-ui")
    use("theHamsta/nvim-dap-virtual-text")
end)
