local M = {}
local config = {}

function M.setup(user_config)
  -- Check ansible-vault availability
  if not require('ansible.utils').is_ansible_vault_available() then
    vim.notify('[Ansible] ansible-vault not found. Install ansible to use this plugin.', vim.log.levels.WARN)
    return
  end

  -- Load defaults
  local defaults = require('ansible.config').defaults

  -- Deep merge user config with defaults (user config takes precedence)
  config = vim.tbl_deep_extend('force', defaults, user_config or {})

  -- Validate merged config
  local valid, err = require('ansible.config').validate(config)
  if not valid then
    vim.notify('[Ansible] Invalid config: ' .. err, vim.log.levels.ERROR)
    return
  end

  -- Setup keymaps if enabled
  if config.keymaps.enabled then
    require('ansible.keymaps').setup(config.keymaps)
  end

  -- Setup commands if enabled
  if config.commands.enabled then
    require('ansible.commands').setup()
  end
end

function M.get_config()
  return config
end

function M.encrypt_inline()
  local vault = require('ansible.vault')
  local ui = require('ansible.ui')
  local selection = ui.get_visual_selection()
  vault.execute_inline_with_file_picker_vault("ansible-vault encrypt_string", selection)
end

function M.decrypt_inline()
  local vault = require('ansible.vault')
  local ui = require('ansible.ui')
  local selection = require('ansible.utils').trim(ui.get_visual_selection())
  vault.execute_inline_with_file_picker_vault("ansible-vault view", selection)
end

function M.encrypt_file()
  local vault = require('ansible.vault')
  vault.execute_with_file_picker_vault("ansible-vault encrypt", "Select file to encrypt")
end

function M.decrypt_file()
  local vault = require('ansible.vault')
  vault.execute_with_file_picker_vault("ansible-vault decrypt", "Select file to decrypt")
end

function M.view_file()
  local vault = require('ansible.vault')
  vault.execute_with_file_picker_vault("ansible-vault view", "Select file to view")
end

return M
