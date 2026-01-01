local M = {}

function M.has_telescope()
  local ok, _ = pcall(require, "telescope.builtin")
  return ok
end

function M.select_file(title, callback)
  local config = require('ansible').get_config()

  if config.file_picker.prefer_telescope and M.has_telescope() then
    local telescope = require('telescope.builtin')
    telescope.find_files({
      prompt_title = title,
      attach_mappings = function(_, map)
        map("i", "<CR>", function(prompt_bufnr)
          local selection = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
          require("telescope.actions").close(prompt_bufnr)
          if selection then
            callback(selection.value)
          end
          return true
        end)
        return true
      end,
      hidden = config.file_picker.telescope_opts.hidden,
      no_ignore = config.file_picker.telescope_opts.no_ignore,
    })
  elseif config.file_picker.fallback_to_vim_ui then
    -- Fallback: use vim.fn.input with custom title
    local input = vim.fn.input(title .. ": ")
    if input and input ~= "" then
      callback(input)
    end
  else
    vim.notify('[Ansible] Telescope not available and fallback disabled', vim.log.levels.WARN)
  end
end

return M
