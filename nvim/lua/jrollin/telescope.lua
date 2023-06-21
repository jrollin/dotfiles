if not pcall(require, "telescope") then
    return
end
-- custom search
local actions = require("telescope.actions")
local utils = require("telescope.utils")

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
    -- local project_root = require("nvim-rooter").get_root()
    require("telescope.builtin").find_files({
        prompt_title = "< files >",
        file_ignore_patterns = { "%.ttf", "%.min.js", "%.min.css" },
        -- cwd = project_root,
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
return M
