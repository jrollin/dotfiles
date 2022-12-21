-- custom search
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
    if vim.fn.system("git rev-parse --is-inside-work-tree") == true then
        M.search_git()
    else
        require("telescope.builtin").find_files()
    end
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
