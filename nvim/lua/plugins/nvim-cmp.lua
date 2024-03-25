local config = function()
  -- completion
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local luasnip = require("luasnip")
  local types = require("luasnip.util.types")
  local cmp = require("cmp")
  local lspkind = require("lspkind")
  --
  -- If you want insert `(` after select function or method item
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

  -- snip
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_lua").lazy_load({ path = "~/.config/nvim/snippets/" })

  luasnip.setup({
    history = true, -- keep around last snippet local to jump back
    updateevents = "TextChanged, TextChangedI",
    -- enable_autosnippets = true,
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { "●", "GruvboxOrange" } },
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { "●", "GruvboxBlue" } },
        },
      },
    },
  })

  --  completion
  --  Set completeopt to have a better completion experience
  vim.opt.completeopt = { "menu", "menuone", "noselect" }
  --
  vim.opt.shortmess:append("c")
  -- limit height window
  vim.o.pumheight = 20

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-u>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
      -- ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
      -- ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    sources = {
      { name = "nvim_lua" },
      { name = "luasnip", keyword_length = 2 },
      -- disable lsp snippet (use luasnip)
      {
        name = "nvim_lsp",
        entry_filter = function(entry)
          return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
        end,
      },
      { name = "nvim_lsp_signature_help" },
      { name = "path" }, -- file paths
      { name = "buffer", keyword_length = 4 },
      { name = "crates" },
    },
    formatting = {
      format = lspkind.cmp_format({
        mode = "symbol_text",
        menu = {
          buffer = "[buf]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[lua]",
          nvim_lsp_signature_help = "[LSP param]",
          path = "[path]",
          luasnip = "[snip]",
        },
      }),
    },
  })

  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
    local col = vim.fn.col(".") - 1
    if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
      return true
    else
      return false
    end
  end

  _G.tab_complete = function()
    if cmp and cmp.visible() then
      cmp.select_next_item()
    elseif luasnip and luasnip.expand_or_jumpable() then
      return t("<Plug>luasnip-expand-or-jump")
    elseif check_back_space() then
      return t("<Tab>")
    else
      cmp.complete()
    end
    return ""
  end
  _G.s_tab_complete = function()
    if cmp and cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip and luasnip.jumpable(-1) then
      return t("<Plug>luasnip-jump-prev")
    else
      return t("<S-Tab>")
    end
    return ""
  end

  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
  vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
  vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
  vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
  -- if active node change choice
  _G.lschoice = function()
    if luasnip.choice_active() then
      return t("<Plug>luasnip-next-choice")
    else
      return t("<Tab>")
    end
  end

  vim.api.nvim_set_keymap("s", "<C-E>", "v:lua.lschoice()", {
    expr = true,
  })
  vim.api.nvim_set_keymap("i", "<C-E>", "v:lua.lschoice()", {
    expr = true,
  })

  -- Setup lspconfig with cmp
end

return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    -- snippets
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    -- format cmp sugestion
    "onsails/lspkind-nvim",
  },

  config = config,
}
