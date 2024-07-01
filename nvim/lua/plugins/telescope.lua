local config = function()
  local actions = require("telescope.actions")
  local previewers = require("telescope.previewers")
  local builtin = require("telescope.builtin")

  local M = {}
  M.search_dotfiles = function()
    require("telescope.builtin").find_files({
      prompt_title = "< dotfiles >",
      cwd = "$HOME/dotfiles/",
    })
  end
  M.search_config = function()
    require("telescope.builtin").find_files({
      prompt_title = "< configfiles >",
      cwd = "$HOME/.config/",
      hidden = true,
    })
  end

  M.search_files = function()
    local project_root = require("nvim-rooter").get_root()
    print("root", project_root)
    require("telescope.builtin").find_files({
      prompt_title = "< files in " .. project_root .. " >",
      file_ignore_patterns = { "%.ttf", "%.min.js", "%.min.css" },
      cwd = project_root,
    })
  end

  M.grep_files = function()
    local project_root = require("nvim-rooter").get_root()
    print("root", project_root)
    require("telescope.builtin").live_grep({
      prompt_title = "< grep files in " .. project_root .. " >",
      cwd = project_root,
    })
  end

  M.list_buffers = function()
    local git_root = vim.fn.system("git rev-parse --is-inside-work-tree")
    require("telescope.builtin").buffers({
      prompt_title = "< My buffers >",
      cwd = git_root,
    })
  end
  M.search_git = function()
    require("telescope.builtin").git_files({
      prompt_title = "< gitfiles >",
      file_ignore_patterns = { "%.min.js", "%.min.css" },
      show_untracked = true,
    })
  end
  M.search_registers = function()
    require("telescope.builtin").registers({
      prompt_title = "< paste registers >",
    })
  end
  M.git_branches = function()
    require("telescope.builtin").git_branches({
      attach_mappings = function(_, map)
        map("i", "<c-d>", actions.git_delete_branch)
        map("n", "<c-d>", actions.git_delete_branch)
        return true
      end,
    })
  end
  -- custom file search
  vim.keymap.set("n", "<Leader>g", M.search_git, { desc = "[S]earch [G]it" })
  vim.keymap.set("n", "<Leader>sf", M.search_files, { desc = "[S]earch [F]iles" })
  vim.keymap.set("n", "<leader>sg", M.grep_files, { desc = "[S]earch by G[r]ep" })

  vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
  vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })

  vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "[S]earch [B]uffers" })
  vim.keymap.set("n", "<leader>cb", "<cmd>BufDelOthers<CR>", { desc = "[C]clean [B]uffers" })
  vim.keymap.set("n", "<leader>sq", builtin.quickfix, { desc = "[S]earch [q]uicklist" })
  vim.keymap.set("n", "<leader>sl", builtin.loclist, { desc = "[S]earch [l]oclist" })

  -- git
  vim.keymap.set("n", "<Leader>gb", M.git_branches, { desc = "[G]it [B]ranches" })
  vim.keymap.set("n", "<Leader>gs", builtin.git_status, { desc = "[G]it [S]tatus" })

  -- ignore patterns
  local _bad = { ".*%.min.js", ".*%.min.css", "*.ttf" } -- Put all filetypes that slow you down in this array
  local bad_files = function(filepath)
    for _, v in ipairs(_bad) do
      if filepath:match(v) then
        return false
      end
    end
    return true
  end

  local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    if opts.use_ft_detect == nil then
      opts.use_ft_detect = true
    end
    opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)

    -- ignore large files
    filepath = vim.fn.expand(filepath)
    vim.loop.fs_stat(filepath, function(_, stat)
      if not stat then
        return
      end
      if stat.size > 100000 then
        return
      else
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end
    end)
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
  end

  require("telescope").setup({
    defaults = {
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      prompt_prefix = " >",
      color_devicons = true,
      buffer_previewer_maker = new_maker,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<TAB>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<S-TAB>"] = actions.move_selection_previous,
          ["<Esc>"] = actions.close,
          ["<C-x>"] = false,
          ["<C-q>"] = actions.send_to_qflist,
          ["<C-d>"] = actions.delete_buffer,
        },
      },
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      },
      media_files = {
        -- filetypes whitelist
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { "png", "webp", "jpg", "jpeg" },
        find_cmd = "rg", -- find command (defaults to `fd`)
      },
      ["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      },
    },
  })
  -- load_extension, somewhere after setup function:
  require("telescope").load_extension("fzy_native")
  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("media_files")
  require("telescope").load_extension("ui-select")
  require("telescope").load_extension("aerial")
  -- require("telescope").load_extension("dap")
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-media-files.nvim",
    "nvim-telescope/telescope-ui-select.nvim", -- Use telescope to override vim.ui.select
    "stevearc/aerial.nvim",
  },
  config = config,
  lazy = false,
}
