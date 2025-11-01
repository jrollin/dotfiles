# 🤖 mistral-codestral.nvim

A comprehensive Neovim plugin for [Mistral AI's Codestral](https://mistral.ai/news/codestral) Fill-in-the-Middle (FIM) API integration, providing intelligent code completion and AI-powered coding assistance.

## ✨ Features

### 🎯 **Multiple Integration Modes**
- **Virtual Text Suggestions** - GitHub Copilot-style inline completions
- **Completion Engine Integration** - Works with `nvim-cmp` and `blink.cmp`  
- **Manual Completions** - On-demand code completion
- **Advanced Completions** - Preview and specialized completion modes

### 🔧 **Smart Context Awareness**
- **Fill-in-the-Middle (FIM)** - Understands prefix and suffix context
- **Enhanced Context** - Intelligent workspace and file analysis
- **Language Detection** - Optimized for 80+ programming languages
- **LSP Integration** - Leverages existing Language Server Protocol data

### ⚡ **Performance & UX**
- **Configurable Delays** - Customize suggestion timing (default 800ms)
- **Minimum Character Thresholds** - Reduce noise with smart triggers
- **Intelligent Caching** - Fast repeated completions
- **Buffer Exclusions** - Skip completions in UI buffers
- **Async Processing** - Non-blocking completions

### 🔒 **Secure Authentication**
- **Multiple Auth Methods** - Keyring, encrypted files, environment variables
- **Command Execution** - Secure API key retrieval from external commands
- **Validation** - Built-in API key testing and health checks

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  dir = vim.fn.stdpath("config") .. "/lua/mistral-codestral",
  name = "mistral-codestral.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- For icons in completion menu
    "saghen/blink.cmp", -- or "hrsh7th/nvim-cmp"
  },
  lazy = false,
  priority = 1000,
  config = function()
    require("mistral-codestral").setup({
      api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
      model = "codestral-latest",
      max_tokens = 256,
      completion_engine = "blink.cmp",
      virtual_text = {
        enabled = true,
        idle_delay = 800,
        min_chars = 3,
      },
    })
  end,
}
```

## 🔑 API Key Setup

### Method 1: File-based (Recommended)
```bash
echo "your_mistral_api_key_here" > ~/.mistral_codestral_key
chmod 600 ~/.mistral_codestral_key
```

### Method 2: Environment Variable
```bash
export MISTRAL_API_KEY="your_mistral_api_key_here"
```

### Method 3: Keyring (Secure)
```lua
require("mistral-codestral").setup({
  api_key = "keyring:mistral-codestral",
})
```

## ⚙️ Configuration

### Basic Configuration

```lua
require("mistral-codestral").setup({
  -- API Configuration
  api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  model = "codestral-latest", -- or "codestral-2405"
  max_tokens = 256,
  temperature = 0.1,
  timeout = 10000,
  
  -- Completion Engine
  completion_engine = "blink.cmp", -- "nvim-cmp", "blink.cmp", "both"
  enable_cmp_source = true,
})
```

### Virtual Text Configuration

```lua
virtual_text = {
  enabled = true,
  manual = false,
  idle_delay = 800,        -- Delay before showing suggestions (ms)
  min_chars = 3,           -- Minimum characters before triggering
  key_bindings = {
    accept = "<Tab>",       -- Accept full completion
    accept_word = "<C-Right>", -- Accept next word
    accept_line = "<C-Down>",  -- Accept current line only
    clear = "<C-c>",        -- Clear suggestions
  },
}
```

### Buffer Exclusions

```lua
exclusions = {
  filetypes = {
    "neo-tree", "help", "alpha", "dashboard", 
    "trouble", "lazy", "mason"
  },
  buffer_patterns = {
    "^neo%-tree", "^NvimTree", "^%[Scratch%]"
  },
  buftypes = {
    "help", "nofile", "quickfix", "terminal", "prompt"
  },
}
```

## 🎮 Usage

### Virtual Text Completions
1. Start typing in any supported file
2. After 3+ characters and 800ms pause, suggestions appear
3. Press `<Tab>` to accept, `<C-c>` to clear

### Manual Completions
- `:MistralCodestralComplete` - Trigger completion at cursor
- `<leader>mc` - Default keybinding for manual completion

### Authentication Management
- `:MistralCodestralAuth status` - Check authentication status
- `:MistralCodestralAuth test` - Test API connection
- `<leader>ma` - Default keybinding for auth status

### Advanced Features
- `:CodestralCompletePreview` - Preview completion before inserting
- `:CodestralClearCache` - Clear completion cache
- `:MistralCodestralToggle` - Toggle plugin on/off

## 🔧 Integration with Completion Engines

### blink.cmp Integration

```lua
-- In your blink.cmp config
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
        score_offset = -50, -- Lower priority than LSP
      },
    },
  },
  -- Custom icon for Mistral completions
  completion = {
    menu = {
      draw = {
        components = {
          kind_icon = {
            text = function(ctx)
              if ctx.source_name == "mistral_codestral" then
                return "󰭶" -- Nerd font robot/AI icon
              end
              return ctx.kind_icon .. ctx.icon_gap
            end,
          },
        },
      },
    },
  },
}
```

### nvim-cmp Integration

```lua
-- In your nvim-cmp config
require('cmp').setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'mistral_codestral', max_item_count = 3 },
    { name = 'buffer' },
  })
})
```

## 🩺 Health Check

Run `:checkhealth mistral-codestral` to verify:
- ✅ Dependencies (plenary.nvim, curl)
- ✅ API key configuration
- ✅ Network connectivity
- ✅ Completion engine integration
- ✅ Virtual text functionality

## 🎛️ Commands

| Command | Description |
|---------|-------------|
| `:MistralCodestralComplete` | Manual completion at cursor |
| `:MistralCodestralToggle` | Toggle plugin on/off |
| `:MistralCodestralAuth [status\\|test]` | Authentication management |
| `:MistralCodestralVirtualComplete` | Trigger virtual text completion |
| `:MistralCodestralVirtualClear` | Clear virtual text suggestions |
| `:CodestralCompletePreview` | Preview completion before inserting |
| `:CodestralClearCache` | Clear completion cache |

## ⌨️ Default Keybindings

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>mc` | Normal | Manual completion |
| `<leader>ma` | Normal | Auth status |
| `<Tab>` | Insert | Accept virtual text / completion menu |
| `<C-Right>` | Insert | Accept next word (virtual text) |
| `<C-Down>` | Insert | Accept current line (virtual text) |
| `<C-c>` | Insert | Clear virtual text |

## 🎨 Highlights

The plugin uses these highlight groups (customize in your colorscheme):
- `BlinkCmpKindIcon` - Icon highlighting for blink.cmp integration
- `Comment` - Virtual text suggestions (uses existing Comment highlight)

## 🔍 Troubleshooting

### Virtual Text Not Showing
1. Check `:MistralCodestralAuth status`
2. Verify `virtual_text.enabled = true`
3. Ensure you've typed 3+ characters (configurable via `min_chars`)
4. Check buffer isn't in exclusions list

### Completion Menu Issues
1. Verify completion engine is properly configured
2. Check `:checkhealth mistral-codestral`
3. Ensure source is enabled in completion engine config

### API Issues
1. Verify API key: `:MistralCodestralAuth test`
2. Check internet connectivity
3. Verify Mistral API service status

## 🧪 Testing

Comprehensive test suite available for verifying plugin functionality.

### Quick Start Testing

```bash
# Interactive test menu (recommended)
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh

# Quick API verification
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1

# Full integration tests
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

### Documentation

Extensive documentation available in the `docs/` directory:

- **[docs/quick-start.md](docs/quick-start.md)** - Get started testing in 30 seconds
- **[docs/testing-guide.md](docs/testing-guide.md)** - Complete testing methodology
- **[docs/test-report.md](docs/test-report.md)** - Detailed test results and analysis
- **[docs/reference.md](docs/reference.md)** - Quick reference card

### Directory Structure

```
mistral-codestral/
├── docs/                   # Documentation
│   ├── quick-start.md     # Quick testing guide
│   ├── testing-guide.md   # Complete testing methods
│   ├── test-report.md     # Test results
│   └── reference.md       # Command reference
├── tests/                  # Test suite
│   ├── api_test.lua       # API functionality tests
│   ├── integration_test.lua # Full integration tests
│   ├── plugin_test.lua    # Component tests
│   └── fixtures/          # Test data files
├── scripts/                # Utility scripts
│   └── run_tests.sh       # Interactive test runner
├── *.lua                   # Plugin source files
└── README.md              # This file
```

### Manual Testing

For manual interactive testing:

1. Open a test file:
   ```bash
   nvim ~/.config/nvim/lua/mistral-codestral/tests/fixtures/example.js
   ```

2. Position cursor in blank areas
3. Enter insert mode and type or wait
4. Look for completions with 󰭶 icon (Mistral AI)

See [docs/testing-guide.md](docs/testing-guide.md) for detailed instructions.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable (see [tests/README.md](tests/README.md))
5. Update documentation if needed
6. Run tests to verify: `bash scripts/run_tests.sh`
7. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Credits

- **[Mistral AI](https://mistral.ai/)** - For the powerful Codestral model
- **[blink.cmp](https://github.com/saghen/blink.cmp)** - Modern completion framework
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** - Traditional completion framework
- **Neovim community** - For the amazing ecosystem

---

**Get your Mistral API key**: [Mistral AI Platform](https://console.mistral.ai/)