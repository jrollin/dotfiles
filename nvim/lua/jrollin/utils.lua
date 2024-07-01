-- define common lsp keymap
--
local lsp_keymap = function(bufnr)
  local bufnr = bufnr or 0

  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  local vmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("v", keys, func, { buffer = bufnr, desc = desc })
  end

  local imap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("i", keys, func, { buffer = bufnr, desc = desc })
  end
  -- Keybindings for LSPs
  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>td", vim.lsp.buf.type_definition, "[T]ype [D]efinition")

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
  imap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lsp actions
  nmap("<leader>r", vim.lsp.buf.rename, "[R]ename")
  nmap("<leader>a", vim.lsp.buf.code_action, "[A]ction")
  -- vmap("<leader>a", vim.lsp.buf.range_code_action, "Range [A]ction")

  nmap("<leader>ll", vim.lsp.codelens.run, "Code [L]ens ")
  nmap("<leader>lr", vim.lsp.codelens.refresh, "Code [L]ens [R]efresh")
end

return { lsp_keymap = lsp_keymap }
