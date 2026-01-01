# 🤖 mistral-codestral.nvim

Intelligent code completion for Neovim using [Mistral Codestral](https://mistral.ai/) AI. Works with `blink.cmp` and `nvim-cmp`.

## ⚡ Quick Start

### 1. Install

Using lazy.nvim:

```lua
return {
  dir = vim.fn.stdpath("config") .. "/lua/mistral-codestral",
  name = "mistral-codestral.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "saghen/blink.cmp",  -- or "hrsh7th/nvim-cmp"
  },
  lazy = false,
  priority = 1000,
  config = function()
    require("mistral-codestral").setup({
      api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
      model = "codestral-latest",
      completion_engine = "blink.cmp",
      virtual_text = { enabled = true, idle_delay = 800 },
    })
  end,
}
```

### 2. Setup API Key

```bash
# Save your API key (get one at https://console.mistral.ai/)
echo "your_key_here" > ~/.mistral_codestral_key
chmod 600 ~/.mistral_codestral_key
```

### 3. Start Using

- **Type in any file** → Suggestions appear after 800ms idle
- **Press `<M-l>`** → Accept completion
- **Press `<C-c>`** → Clear suggestion
- **`:MistralCodestralComplete`** → Manual trigger

## 📚 Documentation

- **[CONFIGURATION.md](docs/CONFIGURATION.md)** - All config options with examples
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - How the plugin works (flows, design)
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[VIRTUAL-TEXT.md](docs/VIRTUAL-TEXT.md)** - Virtual text mode details
- **[COMPLETION-ENGINES.md](docs/COMPLETION-ENGINES.md)** - nvim-cmp & blink.cmp setup

## 🔑 Commands & Bindings

| Command | Key | Description |
|---------|-----|-------------|
| `:MistralCodestralComplete` | `<leader>mc` | Manual completion |
| `:MistralCodestralAuth status` | `<leader>ma` | Check API key |
| `:MistralCodestralToggle` | - | Enable/disable plugin |
| `:checkhealth mistral-codestral` | - | Verify setup |

**Insert mode bindings:**
- `<M-l>` - Accept completion
- `<C-Right>` - Accept next word (virtual text)
- `<C-Down>` - Accept current line (virtual text)
- `<C-c>` - Clear suggestion

## ✨ Features

- **Virtual text** - GitHub Copilot-style inline suggestions
- **Completion menus** - Integrated with blink.cmp and nvim-cmp
- **Context-aware** - Understands your code structure via LSP
- **Smart caching** - Faster repeated completions
- **Buffer exclusions** - Skips UI buffers (help, neo-tree, etc.)
- **Non-blocking** - Async API calls don't interrupt typing

## 🩺 Verify Installation

```bash
# Run health check
nvim +checkhealth\ mistral-codestral

# Quick API test
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1

# Interactive test
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh
```

## ❓ Need Help?

1. Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues
2. Run `:MistralCodestralAuth status` to check API key
3. Run `:checkhealth mistral-codestral` to verify setup
4. Review [CONFIGURATION.md](docs/CONFIGURATION.md) for available options

## 📄 License

MIT - See LICENSE file for details

---

**Get API key**: [Mistral Console](https://console.mistral.ai/)