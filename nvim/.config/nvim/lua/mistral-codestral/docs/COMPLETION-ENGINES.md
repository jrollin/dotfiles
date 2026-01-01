# Completion Engines Integration

How to set up Mistral Codestral with blink.cmp and nvim-cmp.

## Quick Setup

### blink.cmp (Recommended - Modern & Fast)

```lua
-- In your blink.cmp config
return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "mistral_codestral", "buffer" },
      providers = {
        mistral_codestral = {
          name = "mistral_codestral",
          module = "mistral-codestral.blink",
          enabled = true,
          async = true,
          max_items = 1,
          min_keyword_length = 3,
          score_offset = -50,
        },
      },
    },
  },
}
```

### nvim-cmp (Traditional & Mature)

```lua
-- In your nvim-cmp config
return {
  "hrsh7th/nvim-cmp",
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "mistral_codestral", max_item_count = 3 },
        { name = "buffer" },
      }),
    })
  end,
}
```

## Which to Choose?

### blink.cmp (If in doubt, use this)

**Pros:**
- ✅ Fast and modern
- ✅ Better fuzzy matching
- ✅ Lower memory footprint
- ✅ Works with latest features

**Cons:**
- ⚠️ Newer project (less battle-tested)
- ⚠️ Requires Neovim 0.10+

**Best for:**
- New Neovim setups
- Performance-conscious users
- People using latest Neovim

### nvim-cmp (Stable Option)

**Pros:**
- ✅ Mature and stable
- ✅ Works with older Neovim
- ✅ Well-documented
- ✅ Huge community

**Cons:**
- ⚠️ Slightly slower than blink
- ⚠️ More configuration options
- ⚠️ Heavier memory usage

**Best for:**
- Older Neovim versions
- Users with mature setups
- Maximum compatibility

## Detailed Configuration

### blink.cmp Full Example

```lua
return {
  "saghen/blink.cmp",
  version = "v0.10.*",  -- Specify version to avoid breaking changes

  dependencies = {
    "rafamadriz/friendly-snippets",
  },

  opts = {
    -- Mistral Codestral source configuration
    sources = {
      -- Which sources to use by default
      default = { "lsp", "path", "snippets", "mistral_codestral", "buffer" },

      -- Detailed configuration for each source
      providers = {
        mistral_codestral = {
          name = "mistral_codestral",
          module = "mistral-codestral.blink",  -- Must match plugin location
          enabled = true,
          async = true,                         -- Run API call async

          -- Appearance options
          max_items = 1,                        -- Only show 1 option
          min_keyword_length = 3,               -- Wait for 3 chars
          score_offset = -50,                   -- Lower priority than LSP
        },

        -- Other sources...
        lsp = { min_keyword_length = 0 },
        buffer = { min_keyword_length = 5 },
        snippets = { max_items = 3 },
      },
    },

    -- Menu appearance
    completion = {
      menu = {
        -- Custom icons for each source
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                if ctx.source_name == "mistral_codestral" then
                  return "󰭶"  -- Robot icon for Mistral
                end
                return ctx.kind_icon .. ctx.icon_gap
              end,
            },
          },
        },
      },
    },

    -- Fuzzy matching options
    fuzzy = {
      prebuilt_binaries = {
        download = true,
        force_download = false,
      },
    },
  },
}
```

### nvim-cmp Full Example

```lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },

  config = function()
    local cmp = require("cmp")

    cmp.setup({
      -- Snippet engine configuration
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },

      -- Keybindings
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),

      -- Source configuration
      sources = cmp.config.sources({
        {
          name = "nvim_lsp",
          priority = 1000,
        },
        {
          name = "mistral_codestral",
          max_item_count = 3,
          priority = 700,
        },
        {
          name = "luasnip",
          priority = 600,
        },
        {
          name = "buffer",
          priority = 500,
        },
        {
          name = "path",
          priority = 400,
        },
      }),

      -- Sorting and filtering
      sorting = {
        priority_weight = 2,
        length_bias = 0,
        recently_used = true,
        exact = 2,
      },
    })

    -- Command line completion
    cmp.setup.cmdline(":", {
      sources = cmp.config.sources(
        { { name = "cmdline" } },
        { { name = "path" } }
      ),
    })
  end,
}
```

## Priority and Ordering

Both engines show completions in priority order. Mistral should be below LSP.

### blink.cmp Priority (score_offset)

```lua
-- Higher score = higher priority
LSP             → score_offset = 100 (highest)
Path            → score_offset = 50
Snippets        → score_offset = 0
Mistral         → score_offset = -50  ← Lower, appears below others
Buffer          → score_offset = -100
```

Why lower? LSP suggestions are usually more accurate. Mistral is a fallback when LSP can't help.

### nvim-cmp Priority

```lua
-- Higher priority = shown first
local priority = {
  nvim_lsp = 1000,
  mistral_codestral = 700,
  snippets = 600,
  buffer = 500,
  path = 400,
}
```

## Item Customization

### blink.cmp - Custom Icon

Make Mistral items stand out:

```lua
providers = {
  mistral_codestral = {
    name = "mistral_codestral",
    module = "mistral-codestral.blink",
  },
},

completion = {
  menu = {
    draw = {
      components = {
        kind_icon = {
          text = function(ctx)
            if ctx.source_name == "mistral_codestral" then
              return "󰭶 "  -- Custom icon + space
            end
            return ctx.kind_icon .. ctx.icon_gap
          end,
        },

        -- Customize label highlighting
        label = {
          width = { max = 60 },
          text = function(ctx)
            if ctx.source_name == "mistral_codestral" then
              return "AI: " .. ctx.label  -- Prefix with "AI:"
            end
            return ctx.label
          end,
        },
      },
    },
  },
}
```

### nvim-cmp - Custom Formatting

```lua
cmp.setup({
  formatting = {
    format = function(entry, vim_item)
      -- Custom icon for Mistral
      if entry.source.name == "mistral_codestral" then
        vim_item.kind = "󰭶 AI"
        vim_item.abbr = vim_item.abbr:sub(1, 40) .. "..."
      end
      return vim_item
    end,
  },
})
```

## Troubleshooting

### Mistral completions not appearing

**blink.cmp:**
1. Check source is in `default` list
2. Verify `enabled = true`
3. Check `score_offset` isn't hiding it too low
4. Run `:checkhealth mistral-codestral`

**nvim-cmp:**
1. Check source is registered
2. Verify `max_item_count` > 0
3. Check priority value
4. Run `:checkhealth mistral-codestral`

### Completions are slow

**Reduce timeout:**
```lua
timeout = 5000  -- 5 seconds instead of 10
```

**Or increase delay:**
```lua
virtual_text = {
  idle_delay = 1000  -- Wait longer before requesting
}
```

### Too many/too few items showing

**blink.cmp:**
```lua
max_items = 1    -- Show only one
max_items = 5    -- Show up to 5
```

**nvim-cmp:**
```lua
max_item_count = 3    -- Max 3 items
```

### LSP is hiding Mistral

This is normal behavior. LSP suggestions are usually better. If you want to see Mistral:

**blink.cmp:**
```lua
-- Increase score_offset (but still below LSP)
score_offset = 0  -- Same priority as path
```

**nvim-cmp:**
```lua
-- Increase priority (but still below LSP)
priority = 900  -- Closer to LSP's 1000
```

### Integration conflicts

If Mistral source fails to load:

1. Verify plugin path is correct
2. Check module name matches:
   - blink.cmp: `"mistral-codestral.blink"`
   - nvim-cmp: Auto-registered if enabled
3. Check for Lua errors: `:messages`

## Performance Comparison

### blink.cmp
- **Response time**: 50-100ms
- **Memory**: Lower
- **CPU**: Optimized
- **UI responsiveness**: Excellent

### nvim-cmp
- **Response time**: 80-150ms
- **Memory**: Higher
- **CPU**: Good
- **UI responsiveness**: Good

Differences are minimal for most users. Choose based on preferences.

## Switching Between Engines

To switch from nvim-cmp to blink.cmp:

1. Remove nvim-cmp from dependencies
2. Add blink.cmp to dependencies
3. Update completion_engine setting:
   ```lua
   require("mistral-codestral").setup({
     completion_engine = "blink.cmp",
   })
   ```
4. Restart Neovim

To use both:

```lua
require("mistral-codestral").setup({
  completion_engine = "both",
})
```

(Not recommended - may cause duplicate items)

## Using Without Menu

If you want Mistral but not the completion menu:

```lua
require("mistral-codestral").setup({
  enable_cmp_source = false,    -- Disable menu integration
  virtual_text = {
    enabled = true,              -- But keep virtual text
  },
})
```

Then:
- Virtual text still shows
- Manual command still works
- No completion menu items

Perfect for minimal setup.

---

See [CONFIGURATION.md](CONFIGURATION.md) for plugin options.
See [ARCHITECTURE.md](ARCHITECTURE.md) for how it works.
