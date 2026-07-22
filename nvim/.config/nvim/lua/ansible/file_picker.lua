local M = {}

function M.select_file(title, callback)
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    -- hidden/no_ignore: vault password files are often dotfiles or gitignored
    fzf.files({
      prompt = title .. "> ",
      hidden = true,
      no_ignore = true,
      actions = {
        ["enter"] = function(selected)
          local entry = selected and selected[1]
          if entry then
            callback(require("fzf-lua.path").entry_to_file(entry).path)
          end
        end,
      },
    })
  else
    vim.ui.input({ prompt = title .. ": " }, function(input)
      if input and input ~= "" then
        callback(input)
      end
    end)
  end
end

return M
