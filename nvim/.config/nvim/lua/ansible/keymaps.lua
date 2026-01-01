local M = {}
local vault = require('ansible.vault')
local ui = require('ansible.ui')

function M.setup(keymap_config)
  local config = require('ansible').get_config()

  if keymap_config.inline_encrypt then
    vim.keymap.set("v", keymap_config.inline_encrypt, function()
      -- Exit visual mode first
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      -- Wait before getting selection
      vim.defer_fn(function()
        local selection = ui.get_visual_selection()
        vault.execute_inline_with_file_picker_vault("ansible-vault encrypt_string", selection)
      end, config.ui.defer_visual_ms)
    end, { desc = "Ansible Vault encrypt selection with vault file" })
  end

  if keymap_config.inline_decrypt then
    vim.keymap.set("v", keymap_config.inline_decrypt, function()
      -- Exit visual mode first
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      -- Wait before getting selection
      vim.defer_fn(function()
        local selection = ui.get_visual_selection()
        selection = require('ansible.utils').trim(selection)
        vault.execute_inline_with_file_picker_vault("ansible-vault view", selection)
      end, config.ui.defer_visual_ms)
    end, { desc = "Ansible Vault decrypt selection with vault file" })
  end

  if keymap_config.file_decrypt then
    vim.keymap.set("n", keymap_config.file_decrypt, function()
      vault.execute_with_file_picker_vault("ansible-vault view", "Select encrypted file to view")
    end, { desc = "Ansible Vault view with vault file" })
  end

  if keymap_config.file_encrypt then
    vim.keymap.set("n", keymap_config.file_encrypt, function()
      vault.execute_with_file_picker_vault("ansible-vault encrypt", "Select file to encrypt")
    end, { desc = "Ansible Vault encrypt with vault file" })
  end
end

return M
