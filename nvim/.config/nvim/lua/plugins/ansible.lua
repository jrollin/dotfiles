return {
  dir = vim.fn.stdpath("config") .. "/lua/ansible",
  name = "ansible.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim", optional = true },
  },
  lazy = true,
  keys = {
    { "<leader>aie", mode = "v", desc = "Ansible Vault encrypt selection with vault file" },
    { "<leader>aiv", mode = "v", desc = "Ansible Vault decrypt selection with vault file" },
    { "<leader>afe", desc = "Ansible Vault encrypt file with vault file" },
    { "<leader>afv", desc = "Ansible Vault decrypt file with vault file" },
  },
  cmd = {
    "AnsibleVaultEncrypt",
    "AnsibleVaultDecrypt",
    "AnsibleVaultView",
  },
  cond = function()
    return vim.fn.executable("ansible-vault") == 1
  end,
  config = function()
    local ok, ansible = pcall(require, "ansible")
    if not ok then
      vim.notify("[Ansible] Failed to load ansible module", vim.log.levels.ERROR)
      return
    end

    local setup_ok, err = pcall(ansible.setup, {
      keymaps = {
        enabled = true,
        inline_encrypt = "<leader>aie",
        inline_decrypt = "<leader>aiv",
        file_encrypt = "<leader>afe",
        file_decrypt = "<leader>afv",
      },
    })

    if not setup_ok then
      vim.notify("[Ansible] Setup failed: " .. tostring(err), vim.log.levels.ERROR)
    end
  end,
}
