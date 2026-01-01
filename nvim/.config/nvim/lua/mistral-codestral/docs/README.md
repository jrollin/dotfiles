# Mistral Codestral Plugin - Documentation

Complete documentation for the Mistral Codestral Neovim plugin.

## Quick Navigation

### Getting Started
- **[Main README](../README.md)** - Overview, quick start, basic usage
- **[CONFIGURATION.md](CONFIGURATION.md)** - All configuration options

### Learning How It Works
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Complete technical documentation
- **[VIRTUAL-TEXT.md](VIRTUAL-TEXT.md)** - Virtual text mode details
- **[COMPLETION-ENGINES.md](COMPLETION-ENGINES.md)** - blink.cmp & nvim-cmp setup

### Troubleshooting
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions

### Other Resources
- **[quick-start.md](quick-start.md)** - 30-second testing guide
- **[reference.md](reference.md)** - Quick reference card (legacy)

## Documentation Map

```
├── ../README.md                    ← START HERE (5 min read)
│
├── CONFIGURATION.md                ← All config options
│   └── How to customize the plugin
│
├── VIRTUAL-TEXT.md                 ← Virtual text details
│   └── GitHub Copilot-style inline suggestions
│
├── COMPLETION-ENGINES.md           ← Menu integration
│   └── blink.cmp & nvim-cmp setup
│
├── ARCHITECTURE.md                 ← How it works
│   └── Technical flows, design patterns, state management
│
├── TROUBLESHOOTING.md              ← Common issues
│   └── Problem solving guide
│
└── quick-start.md                  ← 30-second testing
    └── One-liner tests & verification
```

## By Task

### "I want to install and use it"
1. Read [../README.md](../README.md)
2. Follow quick start section
3. Run `:checkhealth mistral-codestral`

### "How do I configure it?"
1. Read [CONFIGURATION.md](CONFIGURATION.md)
2. Refer to examples for your use case
3. Check [../README.md](../README.md) for common setups

### "I want virtual text suggestions"
1. Read [VIRTUAL-TEXT.md](VIRTUAL-TEXT.md)
2. Configure in [CONFIGURATION.md](CONFIGURATION.md) → Virtual Text section
3. Troubleshoot in [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if issues

### "I want completion menu items"
1. Read [COMPLETION-ENGINES.md](COMPLETION-ENGINES.md)
2. Choose between blink.cmp or nvim-cmp
3. Follow setup instructions
4. Refer to [CONFIGURATION.md](CONFIGURATION.md) for tuning

### "How does it work internally?"
1. Read [ARCHITECTURE.md](ARCHITECTURE.md)
2. See flows for virtual text, menus, context extraction
3. Understand caching and state management

### "Something isn't working"
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Run `:checkhealth mistral-codestral`
3. Run [quick-start.md](quick-start.md) tests
4. Check debug logs: `:messages`

## Documentation Goals

Each document serves a specific purpose:

- **README.md** - Get you up and running fast
- **CONFIGURATION.md** - Complete reference for all options
- **ARCHITECTURE.md** - Understand the design and how components work
- **VIRTUAL-TEXT.md** - Master the inline suggestion feature
- **COMPLETION-ENGINES.md** - Integrate with your completion engine
- **TROUBLESHOOTING.md** - Solve problems
- **quick-start.md** - Verify installation works

## No Overlapping Content

Each document has a specific scope:

- **Config** → Go to CONFIGURATION.md
- **How it works** → Go to ARCHITECTURE.md
- **Virtual text** → Go to VIRTUAL-TEXT.md
- **Menu integration** → Go to COMPLETION-ENGINES.md
- **Problems** → Go to TROUBLESHOOTING.md
- **Setup** → Go to ../README.md

## Testing and Verification

To test the plugin works:

```bash
# Interactive test menu
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh

# Quick API test
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1

# Full integration test
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

See [quick-start.md](quick-start.md) for more testing options.

## Updates and Maintenance

Last updated: 2025-01-01
Compatible with: Neovim 0.9.0+
Plugin version: Latest

---

**Start with [../README.md](../README.md) for quick setup, then refer to the relevant document for your needs.**
