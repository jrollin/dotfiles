local actions = require('telescope.actions')

local previewers = require("telescope.previewers")

-- ignore patterns
local _bad = { ".*%.min.js", ".*%.min.css" } -- Put all filetypes that slow you down in this array
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
  if opts.use_ft_detect == nil then opts.use_ft_detect = true end
  opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)
  
    -- ignore large files
    filepath = vim.fn.expand(filepath)
      vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then return end
        if stat.size > 100000 then
          return
        else
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
      end)
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
end



require('telescope').setup {
    defaults = {
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        prompt_prefix = ' >',
        color_devicons = true,
        buffer_previewer_maker = new_maker,
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
                ["<C-d>"] = actions.delete_buffer,
            },
        }
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        },
        media_files = {
          -- filetypes whitelist
          -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
          filetypes = {"png", "webp", "jpg", "jpeg"},
          find_cmd = "rg" -- find command (defaults to `fd`)
        }
    }
}

require('telescope').load_extension('fzy_native')
require('telescope').load_extension('file_browser')
require('telescope').load_extension('media_files')

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
    if vim.fn.system "git rev-parse --is-inside-work-tree" == true then
        M.search_git()
    else
        require('telescope.builtin').find_files()
    end
end

M.search_git = function()
    require("telescope.builtin").git_files({
        prompt_title = "< gitfiles >",
        file_ignore_patterns = {"%.min.js", "%.min.css"}
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