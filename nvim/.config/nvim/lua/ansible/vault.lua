local M = {}
local utils = require('ansible.utils')
local ui = require('ansible.ui')
local file_picker = require('ansible.file_picker')

local function execute_command(cmd, callback)
  local buf = ui.create_output_buffer()
  ui.show_in_split(buf)

  -- Initialize buffer with executing message
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Executing command...", "" })
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  local stdout_data = {}
  local stderr_data = {}

  -- Use array form of jobstart to avoid double sh -c wrapping
  local job_cmd = type(cmd) == "table" and cmd or { "sh", "-c", cmd }

  vim.fn.jobstart(job_cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        if type(data) == "table" then
          for _, line in ipairs(data) do
            if line and line ~= "" then
              table.insert(stdout_data, line)
            end
          end
        else
          if data and data ~= "" then
            table.insert(stdout_data, data)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        if type(data) == "table" then
          for _, line in ipairs(data) do
            if line and line ~= "" then
              table.insert(stderr_data, line)
            end
          end
        else
          if data and data ~= "" then
            table.insert(stderr_data, data)
          end
        end
      end
    end,
    on_exit = function(_, code)
      vim.api.nvim_buf_set_option(buf, "modifiable", true)

      local output = {}
      if code == 0 then
        table.insert(output, "✓ Completed:")
        for _, line in ipairs(stdout_data) do
          table.insert(output, line)
        end
      else
        table.insert(output, "✗ Failed (code " .. code .. "):")
        if #stderr_data > 0 then
          for _, line in ipairs(stderr_data) do
            table.insert(output, line)
          end
        elseif #stdout_data > 0 then
          for _, line in ipairs(stdout_data) do
            table.insert(output, line)
          end
        end
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
      vim.api.nvim_buf_set_option(buf, "modifiable", false)

      if callback then
        callback(code == 0)
      end
    end,
  })
end

function M.encrypt_inline(content, vault_file, callback)
  -- Use printf to safely pass content, avoiding quote escaping issues
  local full_cmd = string.format(
    "printf '%%s' %s | tr -d ' ' | ansible-vault encrypt_string --vault-password-file %s",
    vim.fn.shellescape(content),
    vim.fn.shellescape(vault_file)
  )
  execute_command(full_cmd, callback)
end

function M.decrypt_inline(content, vault_file, callback)
  -- Use printf to safely pass content, avoiding quote escaping issues
  local full_cmd = string.format(
    "printf '%%s' %s | tr -d ' ' | ansible-vault decrypt --vault-password-file %s",
    vim.fn.shellescape(content),
    vim.fn.shellescape(vault_file)
  )
  execute_command(full_cmd, callback)
end

function M.encrypt_file(file_path, vault_file, callback)
  local full_cmd = string.format(
    "ansible-vault encrypt %s --vault-password-file %s",
    vim.fn.shellescape(file_path),
    vim.fn.shellescape(vault_file)
  )
  execute_command(full_cmd, callback)
end

function M.decrypt_file(file_path, vault_file, callback)
  local full_cmd = string.format(
    "ansible-vault decrypt %s --vault-password-file %s",
    vim.fn.shellescape(file_path),
    vim.fn.shellescape(vault_file)
  )
  execute_command(full_cmd, callback)
end

function M.view_file(file_path, vault_file, callback)
  local full_cmd = string.format(
    "ansible-vault view %s --vault-password-file %s",
    vim.fn.shellescape(file_path),
    vim.fn.shellescape(vault_file)
  )
  execute_command(full_cmd, callback)
end

function M.execute_inline_with_file_picker_vault(cmd_prefix, selection)
  local config = require('ansible').get_config()

  if config.vault.default_vault_file and not config.vault.prompt_for_vault_file then
    local vault_file = vim.fn.expand(config.vault.default_vault_file)
    if cmd_prefix == "ansible-vault encrypt_string" then
      M.encrypt_inline(selection, vault_file)
    elseif cmd_prefix == "ansible-vault view" then
      M.decrypt_inline(selection, vault_file)
    end
  else
    local vault_prompt = "Select Ansible Vault password file"
    file_picker.select_file(vault_prompt, function(vault_file)
      if cmd_prefix == "ansible-vault encrypt_string" then
        M.encrypt_inline(selection, vault_file)
      elseif cmd_prefix == "ansible-vault view" then
        M.decrypt_inline(selection, vault_file)
      end
    end)
  end
end

function M.execute_with_file_picker_vault(cmd_prefix, title)
  local config = require('ansible').get_config()

  file_picker.select_file(title, function(file_path)
    if config.vault.default_vault_file and not config.vault.prompt_for_vault_file then
      local vault_file = vim.fn.expand(config.vault.default_vault_file)
      if cmd_prefix == "ansible-vault encrypt" then
        M.encrypt_file(file_path, vault_file)
      elseif cmd_prefix == "ansible-vault decrypt" then
        M.decrypt_file(file_path, vault_file)
      elseif cmd_prefix == "ansible-vault view" then
        M.view_file(file_path, vault_file)
      end
    else
      local vault_prompt = "Select Ansible Vault password file"
      file_picker.select_file(vault_prompt, function(vault_file)
        if cmd_prefix == "ansible-vault encrypt" then
          M.encrypt_file(file_path, vault_file)
        elseif cmd_prefix == "ansible-vault decrypt" then
          M.decrypt_file(file_path, vault_file)
        elseif cmd_prefix == "ansible-vault view" then
          M.view_file(file_path, vault_file)
        end
      end)
    end
  end)
end

return M
