return {
  "ibhagwan/fzf-lua",
  optional = true,
  opts = function(_, opts)
    local actions = require("fzf-lua.actions")
    return vim.tbl_deep_extend("force", opts, {
      lsp = {
        -- ruby-lsp references/definition can exceed the 5s default on large monorepos
        async_or_timeout = 20000,
      },
      files = {
        cwd_prompt = false,
        actions = {
          ["Ctrl-i"] = { actions.toggle_ignore },
          ["Ctrl-h"] = { actions.toggle_hidden },
        },
      },
      grep = {
        actions = {
          ["Ctrl-i"] = { actions.toggle_ignore },
          ["Ctrl-h"] = { actions.toggle_hidden },
        },
      },
    })
  end,
}
