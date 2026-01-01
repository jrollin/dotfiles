local M = {}

function M.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function M.escape_single_quotes(str)
  return string.gsub(str, "'", "'\\''")
end

function M.is_ansible_vault_available()
  return vim.fn.executable('ansible-vault') == 1
end

return M
