# Configuration Guide

Complete reference for all Mistral Codestral plugin configuration options.

## Basic Setup

```lua
require("mistral-codestral").setup({
  -- API & Model
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  model = "codestral-latest",
  max_tokens = 256,
  temperature = 0.1,
  timeout = 10000,

  -- Completion Engine
  completion_engine = "blink.cmp",  -- "auto" | "nvim-cmp" | "blink.cmp" | "both"
  enable_cmp_source = true,
  cmp_max_items = 5,

  -- Virtual Text
  virtual_text = {
    enabled = true,
    manual = false,
    idle_delay = 800,
    min_chars = 3,
    priority = 65535,
  },

  -- Exclusions
  exclusions = { ... },
})
```

## API Configuration

### `api_key` (string)

API key for Mistral API authentication. Supports multiple formats:

```lua
-- File-based (recommended)
api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'"

-- Environment variable
api_key = "env:MISTRAL_API_KEY"

-- Keyring
api_key = "keyring:mistral-codestral"

-- Direct (not recommended - store securely instead)
api_key = "your_api_key_here"
```

**Security**: File-based with `chmod 600` is most secure. Keyring is also safe.

### `model` (string)

Which Codestral model to use.

```lua
model = "codestral-latest"     -- Default, always latest
model = "codestral-2405"       -- Specific version
```

### `max_tokens` (number)

Maximum tokens to generate in completion. Lower = faster but shorter suggestions.

```lua
max_tokens = 256    -- Default, balanced
max_tokens = 512    -- Longer completions
max_tokens = 64     -- Short, fast completions
```

### `temperature` (number)

Creativity of responses (0.0 = deterministic, 1.0 = creative).

```lua
temperature = 0.1   -- Default, focused/predictable
temperature = 0.3   -- Slightly creative
temperature = 0.7   -- More creative
```

### `timeout` (number, milliseconds)

How long to wait for API response before timing out.

```lua
timeout = 10000     -- 10 seconds (default)
timeout = 5000      -- 5 seconds (faster, may timeout)
timeout = 30000     -- 30 seconds (slower, more patient)
```

### `stop_tokens` (table)

Tokens that tell the API to stop generating.

```lua
stop_tokens = { "\n\n" }         -- Default: stop at double newline
stop_tokens = { "\n\n", "}" }    -- Multiple stop conditions
```

## Completion Engine Configuration

### `completion_engine` (string)

Which completion engine to use.

```lua
completion_engine = "blink.cmp"     -- Modern, fast (recommended)
completion_engine = "nvim-cmp"      -- Traditional, mature
completion_engine = "auto"          -- Auto-detect (blink.cmp preferred)
completion_engine = "both"          -- Use both engines
```

**Note**: Each engine requires separate installation. See [COMPLETION-ENGINES.md](COMPLETION-ENGINES.md).

### `enable_cmp_source` (boolean)

Whether to register Mistral as a completion source.

```lua
enable_cmp_source = true    -- Enable (recommended)
enable_cmp_source = false   -- Disable (only use manual/virtual text)
```

### `cmp_max_items` (number)

How many Mistral completion items to show in menu.

```lua
cmp_max_items = 5           -- Default: show up to 5 variants
cmp_max_items = 1           -- Only show one option (cleaner)
cmp_max_items = 3           -- Show 3 variants
```

## Virtual Text Configuration

Virtual text shows inline suggestions (Copilot-style).

### `virtual_text.enabled` (boolean)

Turn virtual text on/off.

```lua
virtual_text = {
  enabled = true    -- Default: show inline suggestions
}
```

### `virtual_text.manual` (boolean)

Whether virtual text requires manual trigger or shows automatically.

```lua
virtual_text = {
  manual = false    -- Default: automatic (appears after idle_delay)
  manual = true     -- Manual only: use :MistralCodestralVirtualComplete
}
```

### `virtual_text.idle_delay` (number, milliseconds)

How long to wait before showing suggestion after typing stops.

```lua
virtual_text = {
  idle_delay = 800    -- Default: 800ms = 0.8 seconds
  idle_delay = 200    -- Fast: show quickly
  idle_delay = 1500   -- Patient: less intrusive
}
```

### `virtual_text.min_chars` (number)

Minimum characters needed in current word before triggering suggestion.

```lua
virtual_text = {
  min_chars = 3       -- Default: need "foo" not just "fo"
  min_chars = 1       -- Trigger immediately
  min_chars = 5       -- Only trigger for longer words
}
```

### `virtual_text.priority` (number)

Display priority relative to other virtual text (higher = on top).

```lua
virtual_text = {
  priority = 65535    -- Default: on top of most things
}
```

### `virtual_text.key_bindings` (table)

Keybindings for accepting virtual text completions.

```lua
virtual_text = {
  key_bindings = {
    accept = "<M-l>",          -- Accept full completion
    accept_word = "<C-Right>", -- Accept next word only
    accept_line = "<C-Down>",  -- Accept next line only
    next = "<M-]>",            -- Cycle to next completion
    prev = "<M-[>",            -- Cycle to previous completion
    clear = "<C-c>",           -- Clear suggestion
  }
}
```

## Buffer Exclusions

Disable completions in specific buffers/filetypes.

```lua
exclusions = {
  -- Filetypes to exclude
  filetypes = {
    "neo-tree", "neo-tree-popup",  -- File browsers
    "help", "alpha", "dashboard",  -- UI windows
    "nvim-tree", "trouble",        -- Plugin windows
    "lspinfo", "mason", "lazy",    -- Tool windows
    "TelescopePrompt",             -- Telescope
    "qf",                          -- Quickfix
  },

  -- Buffer name patterns to exclude
  buffer_patterns = {
    "^neo%-tree",
    "^NvimTree",
    "^%[Scratch%]",
    "^term://",
  },

  -- Buffer types to exclude
  buftypes = {
    "help", "nofile", "quickfix",
    "terminal", "prompt",
  },
}
```

**How matching works:**
- `filetypes`: Exact match on `vim.bo.filetype`
- `buffer_patterns`: Lua regex pattern match on buffer name
- `buftypes`: Exact match on `vim.bo.buftype`

### Disable in All Buffers

```lua
exclusions = {
  filetypes = {},           -- Empty = no filetypes excluded
  buffer_patterns = {},
  buftypes = {},
}
```

### Disable in All But Specific Filetypes

```lua
-- Exclude everything EXCEPT lua and python
-- (do this by setting default_filetype_enabled = false)
virtual_text = {
  default_filetype_enabled = false,  -- Disable by default
  filetypes = {
    lua = true,
    python = true,
  }
}
```

## Authentication Configuration

Advanced auth options.

```lua
auth = {
  methods = { "keyring", "encrypted_file", "environment", "config", "prompt" },
  validate_on_startup = true,
  cache_validation = true,
}
```

### `auth.methods` (table)

Ordered list of auth methods to try.

```lua
methods = {
  "keyring",           -- Try secure keyring first
  "encrypted_file",    -- Then encrypted file
  "environment",       -- Then environment variable
  "config",            -- Then direct config value
  "prompt",            -- Finally ask user
}
```

### `auth.validate_on_startup` (boolean)

Check API key is valid when plugin loads.

```lua
validate_on_startup = true   -- Default: verify key works
```

### `auth.cache_validation` (boolean)

Cache validation result to avoid repeated checks.

```lua
cache_validation = true      -- Default: cache for performance
```

## LSP Integration Configuration

```lua
workspace_root = {
  use_lsp = true,    -- Use LSP for workspace root detection
  find_root = nil,   -- Custom function (optional)
  paths = {          -- Fallback workspace indicators
    ".git", ".svn", ".hg",
    "package.json", "Cargo.toml", "pyproject.toml",
    "go.mod", "requirements.txt",
  },
}
```

## Example Configurations

### Minimal (Just Works)

```lua
require("mistral-codestral").setup({
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
})
```

### Conservative (Low Noise)

```lua
require("mistral-codestral").setup({
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  virtual_text = {
    enabled = true,
    idle_delay = 1500,     -- Wait longer
    min_chars = 5,         -- Only for longer words
  },
  cmp_max_items = 1,       -- Only show one option
})
```

### Aggressive (Fast Feedback)

```lua
require("mistral-codestral").setup({
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  max_tokens = 512,        -- Longer completions
  virtual_text = {
    enabled = true,
    idle_delay = 200,      -- Show quickly
    min_chars = 1,         -- Show for everything
  },
  cmp_max_items = 5,       -- Show multiple options
})
```

### Manual Only (No Automatic)

```lua
require("mistral-codestral").setup({
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  enable_cmp_source = false,     -- No completion menu
  virtual_text = {
    enabled = false,               -- No virtual text
  },
})
-- Use only :MistralCodestralComplete or <leader>mc
```

### Development (Debug Mode)

```lua
require("mistral-codestral").setup({
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  debug = true,              -- Enable debug logging
  virtual_text = {
    enabled = true,
    idle_delay = 500,
    min_chars = 3,
  },
})
-- Check :messages for debug output
```

## Configuration Precedence

Configuration values are determined in this order:

1. **Setup config** - What you pass to `setup()`
2. **Environment variables** - For `api_key = "env:VAR_NAME"`
3. **Keyring** - For `api_key = "keyring:key_name"`
4. **Default values** - Built-in defaults

## Tips

- **Performance**: Lower `idle_delay` and `max_tokens` for faster feedback
- **Quality**: Higher `max_tokens` and `temperature` for better suggestions
- **Comfort**: Higher `idle_delay` and `min_chars` for less intrusive behavior
- **Testing**: Set `debug = true` to see what's happening

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if things aren't working as expected.
