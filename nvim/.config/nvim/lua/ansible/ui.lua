local M = {}
local utils = require('ansible.utils')

function M.get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  local lines = vim.fn.getline(start_line, end_line)

  local mode = vim.fn.visualmode()
  if mode == "v" then
    if start_line == end_line then
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
  elseif mode == "V" then
    -- Full line mode - no adjustments needed
  elseif mode == "\22" then
    -- Block mode (Ctrl+v)
    local width = end_col - start_col + 1
    for i = 1, #lines do
      lines[i] = string.sub(lines[i], start_col, start_col + width - 1)
    end
  end

  return table.concat(lines, "\n")
end

function M.create_output_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  local config = require('ansible').get_config()
  vim.api.nvim_buf_set_option(buf, "filetype", config.ui.output_filetype)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  return buf
end

function M.show_in_split(bufnr)
  local config = require('ansible').get_config()
  vim.cmd(config.ui.split)
  vim.api.nvim_win_set_buf(0, bufnr)
end

function M.display_output(bufnr, data, success)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

  local lines = {}
  if success then
    table.insert(lines, "✓ Completed:")
  else
    table.insert(lines, "✗ Failed:")
  end

  if data and #data > 0 then
    for _, line in ipairs(data) do
      table.insert(lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

return M
