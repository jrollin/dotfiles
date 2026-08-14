-- markdown-preview.nvim vendors mermaid 10.2.3 and is unmaintained since 2023, so the bundled
-- copy is overwritten on build. mermaid 11 keeps the UMD global and the deprecated `init()` the
-- plugin calls, so it is a drop-in swap.
-- Overwriting a git-tracked file makes lazy refuse to update the plugin, so the build hook marks
-- it skip-worktree. If upstream ever touches mermaid.min.js, git pull will fail there: run
-- `git update-index --no-skip-worktree app/_static/mermaid.min.js` in the plugin dir, then rebuild.
local mermaid_version = "11.16.1"

return {

  {
    "iamcco/markdown-preview.nvim",
    -- replaces LazyVim's build hook, hence the mkdp install call
    build = function(plugin)
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()

      local dest = plugin.dir .. "/app/_static/mermaid.min.js"
      local tmp = dest .. ".tmp"
      local url = ("https://cdn.jsdelivr.net/npm/mermaid@%s/dist/mermaid.min.js"):format(mermaid_version)
      local res = vim.system({ "curl", "-fsSL", "-o", tmp, url }):wait()
      if res.code ~= 0 then
        vim.fn.delete(tmp)
        error(("mermaid %s download failed (%s): %s"):format(mermaid_version, url, res.stderr or ""))
      end
      assert(vim.uv.fs_rename(tmp, dest))

      -- lazy's dirty check is `git ls-files -d -m`, which honors skip-worktree
      vim.system({ "git", "update-index", "--skip-worktree", "app/_static/mermaid.min.js" }, { cwd = plugin.dir })
        :wait()
    end,
    keys = {
      {
        "<leader>mp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- For `nvim-treesitter` users.
    priority = 49,
    opts = {},
    config = function()
      local presets = require("markview.presets")
      local glow = presets.headings.glow
      -- override
      glow.shift_width = 0

      require("markview").setup({
        preview = {
          filetypes = { "markdown", "codecompanion", "avante" },
          ignore_buftypes = {},
        },
        markdown = {
          headings = glow,
          code_blocks = {
            enable = false,
          },
        },
      })
    end,
  },
}
