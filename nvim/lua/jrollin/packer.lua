--local ensure_packer = function()
    local fn = vim.fn
    local install_path = "~/.local/share/nvim/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
--    return false
--end

--local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")
    -- file explorer
    use("kyazdani42/nvim-tree.lua")
    --  color ui
    use("gruvbox-community/gruvbox")
    use("folke/lsp-colors.nvim")
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
    use({
        -- LSP Configuration & Plugins
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
        requires = { "windwp/nvim-ts-autotag", "p00f/nvim-ts-rainbow", "JoosepAlviste/nvim-ts-context-commentstring" },
    })
    use("nvim-treesitter/playground")
    use({
        -- Additional text objects via treesitter
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
    })
    -- idk
    use("jose-elias-alvarez/null-ls.nvim")
    -- format code
    use("tpope/vim-surround")
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    })
    use("editorconfig/editorconfig-vim")
    use("windwp/nvim-autopairs")
    -- telescope
    use("nvim-lua/popup.nvim")
    use("nvim-lua/plenary.nvim")
    use({ "nvim-telescope/telescope.nvim", tag = "0.1.1", requires = { { "nvim-lua/plenary.nvim" } } })
    use("nvim-telescope/telescope-fzy-native.nvim")
    use("nvim-telescope/telescope-file-browser.nvim")
    use("nvim-telescope/telescope-media-files.nvim")
    use({
        "nvim-telescope/telescope-ui-select.nvim", -- Use telescope to override vim.ui.select
        requires = { "nvim-telescope/telescope.nvim" },
    })
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

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)
