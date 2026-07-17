return {
  "ibhagwan/fzf-lua",
  optional = true,
  opts = function(_, opts)
    local actions = require("fzf-lua.actions")
    return vim.tbl_deep_extend("force", opts, {
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
