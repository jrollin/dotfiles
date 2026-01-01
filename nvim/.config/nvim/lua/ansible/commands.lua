local M = {}
local vault = require('ansible.vault')
local file_picker = require('ansible.file_picker')

-- Create commands immediately on module load
vim.api.nvim_create_user_command("AnsibleVaultEncrypt", function(opts)
  local file_path = opts.args and opts.args ~= "" and opts.args or nil

  if file_path then
    -- File provided as argument - skip picker for file
    local config = require('ansible').get_config()
    if config.vault.default_vault_file and not config.vault.prompt_for_vault_file then
      local vault_file = vim.fn.expand(config.vault.default_vault_file)
      vault.encrypt_file(file_path, vault_file)
    else
      file_picker.select_file("Select Ansible Vault password file", function(vault_file)
        vault.encrypt_file(file_path, vault_file)
      end)
    end
  else
    -- No file provided - show picker
    vault.execute_with_file_picker_vault("ansible-vault encrypt", "Select file to encrypt")
  end
end, { nargs = "?", desc = "Encrypt file with ansible-vault" })

vim.api.nvim_create_user_command("AnsibleVaultDecrypt", function(opts)
  local file_path = opts.args and opts.args ~= "" and opts.args or nil

  if file_path then
    -- File provided as argument - skip picker for file
    local config = require('ansible').get_config()
    if config.vault.default_vault_file and not config.vault.prompt_for_vault_file then
      local vault_file = vim.fn.expand(config.vault.default_vault_file)
      vault.decrypt_file(file_path, vault_file)
    else
      file_picker.select_file("Select Ansible Vault password file", function(vault_file)
        vault.decrypt_file(file_path, vault_file)
      end)
    end
  else
    -- No file provided - show picker
    vault.execute_with_file_picker_vault("ansible-vault decrypt", "Select file to decrypt")
  end
end, { nargs = "?", desc = "Decrypt file with ansible-vault" })

vim.api.nvim_create_user_command("AnsibleVaultView", function(opts)
  local file_path = opts.args and opts.args ~= "" and opts.args or nil

  if file_path then
    -- File provided as argument - skip picker for file
    local config = require('ansible').get_config()
    if config.vault.default_vault_file and not config.vault.prompt_for_vault_file then
      local vault_file = vim.fn.expand(config.vault.default_vault_file)
      vault.view_file(file_path, vault_file)
    else
      file_picker.select_file("Select Ansible Vault password file", function(vault_file)
        vault.view_file(file_path, vault_file)
      end)
    end
  else
    -- No file provided - show picker
    vault.execute_with_file_picker_vault("ansible-vault view", "Select file to view")
  end
end, { nargs = "?", desc = "View encrypted file with ansible-vault" })

function M.setup()
  -- Commands are now created on module load, nothing to do here
end

return M
