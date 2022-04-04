local actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        prompt_prefix = ' >',
        color_devicons = true,

        file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<TAB>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<S-TAB>"] = actions.move_selection_previous,
                ["<Esc>"] = actions.close,
                ["<C-x>"] = false,
                ["<C-q>"] = actions.send_to_qflist,
            },
        }
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}

require('telescope').load_extension('fzy_native')
require('telescope').load_extension('file_browser')

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
