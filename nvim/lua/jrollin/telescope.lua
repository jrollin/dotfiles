if not pcall(require, "telescope") then
    return
end
-- custom search
local actions = require("telescope.actions")

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
    require("telescope.builtin").find_files({
        prompt_title = "< files >",
        file_ignore_patterns = { "%.ttf", "%.min.js", "%.min.css" },
    })
end

M.search_git = function()
    require("telescope.builtin").git_files({
        prompt_title = "< gitfiles >",
        file_ignore_patterns = { "%.min.js", "%.min.css" },
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
