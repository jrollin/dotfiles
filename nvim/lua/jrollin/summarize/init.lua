-- local plugin = {}

local function replace_selection()
  local cmd = "cat"
  -- Obtenez la sélection actuelle
  -- local selection = vim.api.nvim_get_current_selection()

  local selection = vim.api.nvim_get_current_selection()
  print(selection.line, selection.col, selection.end_line, selection.end_col)

  -- Exécutez la commande avec la sélection
  local output = vim.fn.system(cmd, { selection = selection })

  -- Remplacez la sélection par la sortie de la commande
  vim.api.nvim_set_current_line(output)
end

local function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  if next(lines) == nil then
    return nil
  end
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, "\n")
end

-- return plugin
vim.api.nvim_create_user_command("Summarize", replace_selection, { range = true })
