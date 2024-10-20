vim.api.nvim_create_user_command("Ansible", function(tbl)
  -- local shortname = vim.fn.expand("%:t:r")
  -- local fullpath = vim.api.nvim_buf_get_name(0)
  local vault = vim.fn.input("Vault pass absolute path: ", "~/projects/homelab/vault_pass")
  local bufnr = 0
  local selected_text = vim.api.nvim_buf_get_lines(bufnr, tbl.line1 - 1, tbl.line2, true)
  local selection = table.concat(selected_text, "\n")
  -- remove whitespace (tr -d ' ')
  selection = string.gsub(selection, "[^%S\n]+", "")

  local buffer_number = -1
  local output = ""

  local function log(_, data)
    if data then
      -- Make it temporarily writable so we don't have warnings.
      vim.api.nvim_buf_set_option(buffer_number, "readonly", false)

      -- Append the data.
      vim.api.nvim_buf_set_lines(buffer_number, -1, -1, true, data)

      -- Make readonly again.
      vim.api.nvim_buf_set_option(buffer_number, "readonly", true)

      -- Mark as not modified, otherwise you'll get an error when
      -- attempting to exit vim.
      vim.api.nvim_buf_set_option(buffer_number, "modified", false)

      -- Get the window the buffer is in and set the cursor position to the bottom.
      local buffer_window = vim.api.nvim_call_function("bufwinid", { buffer_number })
      local buffer_line_count = vim.api.nvim_buf_line_count(buffer_number)
      vim.api.nvim_win_set_cursor(buffer_window, { buffer_line_count, 0 })
    end
  end

  local function open_buffer()
    -- Get a boolean that tells us if the buffer number is visible anymore.
    --
    -- :help bufwinnr
    local buffer_visible = vim.api.nvim_call_function("bufwinnr", { buffer_number }) ~= -1

    if buffer_number == -1 or not buffer_visible then
      -- Create a new buffer with the name "AUTOTEST_OUTPUT".
      -- Same name will reuse the current buffer.
      vim.api.nvim_command("botright vsplit AUTOTEST_OUTPUT")

      -- Collect the buffer's number.
      buffer_number = vim.api.nvim_get_current_buf()

      -- Mark the buffer as readonly.
      -- vim.opt_local.readonly = true
    end
  end

  -- Open our buffer, if we need to.
  open_buffer()

  -- Clear the buffer's contents incase it has been used.
  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, true, {})

  local command = "echo '" .. selection .. "' | ansible-vault decrypt --vault-password-file " .. vault
  vim.fn.jobstart(command, { stdout_buffered = false, on_stdout = log, on_stderr = log })
end, { range = true })
