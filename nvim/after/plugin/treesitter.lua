require("nvim-treesitter.configs").setup({
    highlight = {
        enable = true,
        custom_captures = {
            ["css.prop"] = "cssProp",
            ["css.tag"] = "cssTagName",
            ["css.constant"] = "Constant",
            ["css.class"] = "cssClassName",
        },
        -- disable = { "lua" },
    },
    indent = {
        enable = true,
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
    },
    textobjects = {
        move = {
            enable = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        select = {
            enable = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ar"] = "@block.outer",
                ["ir"] = "@block.inner",
            },
        },
    },
    rainbow = {
        enable = true,
    },
    context_commentstring = {
        enable = true,
        config = {
            lua = "-- %s",
        },
    },
    ensure_installed = {
        "lua",
        "c",
        "query",
        "html",
        "css",
        "javascript",
        "typescript",
        "rust",
        "json",
        "toml",
    },
    autotag = {
        enable = true,
    },
})
