local M = {}

M.defaults = {
  -- Keymap configuration
  keymaps = {
    enabled = true,
    inline_encrypt = '<leader>aie',
    inline_decrypt = '<leader>aiv',
    file_encrypt = '<leader>afe',
    file_decrypt = '<leader>afv',
  },

  -- UI configuration
  ui = {
    split = 'vsplit',              -- 'vsplit', 'split', 'tabnew'
    output_filetype = 'AnsibleOutput',
    show_command = false,           -- Show executed command in output
    defer_visual_ms = 100,          -- Delay before processing visual selection
  },

  -- File picker configuration
  file_picker = {
    prefer_telescope = true,
    fallback_to_vim_ui = true,
    telescope_opts = {
      hidden = true,
      no_ignore = true,
    },
  },

  -- Vault settings
  vault = {
    default_vault_file = nil,       -- Optional: default vault file path
    prompt_for_vault_file = true,   -- Always ask for vault file
  },

  -- Command configuration
  commands = {
    enabled = true,                 -- Enable :AnsibleVault* commands
  },
}

function M.validate(config)
  -- Validate split type
  if config.ui and config.ui.split then
    local valid_splits = { vsplit = true, split = true, tabnew = true }
    if not valid_splits[config.ui.split] then
      return false, "Invalid split type: " .. config.ui.split
    end
  end

  -- Validate defer_visual_ms is a positive number
  if config.ui and config.ui.defer_visual_ms then
    if type(config.ui.defer_visual_ms) ~= 'number' or config.ui.defer_visual_ms < 0 then
      return false, "defer_visual_ms must be a non-negative number"
    end
  end

  return true
end

return M
