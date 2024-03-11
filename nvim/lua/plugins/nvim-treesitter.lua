local config = function()
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
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
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
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["at"] = "@call.outer",
          ["it"] = "@call.inner",
          ["ip"] = "@parameter.inner",
          ["ap"] = "@parameter.outer",
          ["am"] = "@conditional.outer",
          ["im"] = "@conditional.inner",
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
      "query",
      "bash",
      "vim",
      "vimdoc",
      "c",
      "markdown",
      "markdown_inline",
      "html",
      "css",
      "typescript",
      "rust",
      "json",
      "toml",
    },
    autotag = {
      enable = true,
    },
    hightlight = {
      -- list of language that will be disabled
      -- disable = { "c", "rust" },
    },
  })
end

return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "p00f/nvim-ts-rainbow",
    -- Additional text objects via treesitter
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = config,
  lazy = false,
}
