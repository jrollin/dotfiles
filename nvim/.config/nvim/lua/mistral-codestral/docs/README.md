# Mistral Codestral Documentation

This directory contains comprehensive documentation for testing and using the Mistral Codestral plugin.

## Documentation Files

### [quick-start.md](quick-start.md)
**Get started in 30 seconds**

Quick reference guide with one-liner commands to immediately test your Mistral autocomplete installation. Perfect for:
- First-time testing
- Quick verification
- Troubleshooting

**Key sections:**
- Interactive test menu
- One-command tests
- API verification
- Common issues

### [testing-guide.md](testing-guide.md)
**Complete testing methodology**

Comprehensive step-by-step guide covering all testing methods:
- Manual interactive testing
- Automated test scripts
- Visual verification
- Debug mode testing
- Real-world scenarios

**Use this when:**
- Learning how autocomplete works
- Troubleshooting issues
- Understanding expected behavior
- Recording test sessions

### [test-report.md](test-report.md)
**Detailed test results and analysis**

Complete test report from comprehensive testing session including:
- Plugin architecture verification
- API authentication tests
- FIM API functionality tests
- Blink.cmp integration tests
- LSP compatibility verification
- Configuration analysis

**Use this to:**
- Understand what was tested
- See expected test results
- Review plugin capabilities
- Verify your setup matches tested configuration

### [reference.md](reference.md)
**Quick reference card**

Fast lookup reference containing:
- Configuration summary
- Key bindings
- Commands
- Completion settings
- Priority order
- Integration status
- Performance notes
- Example usage

**Use this for:**
- Quick lookups during usage
- Command reference
- Configuration values
- Troubleshooting checklist

## Quick Links

### Start Here
New to testing? Start with:
1. [quick-start.md](quick-start.md) - Test in 30 seconds
2. [testing-guide.md](testing-guide.md) - Learn all methods
3. [reference.md](reference.md) - Keep handy for commands

### Having Issues?
- Check [quick-start.md](quick-start.md) troubleshooting section
- See [testing-guide.md](testing-guide.md) Method 4 for debug mode
- Review [test-report.md](test-report.md) for expected behavior
- Compare your config with [reference.md](reference.md)

### Running Tests
```bash
# Interactive test menu
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh

# Quick API verification
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1

# Full integration tests
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

## Documentation Standards

These docs follow Neovim plugin documentation best practices:

### Structure
- **Markdown format** for readability
- **Clear headings** for navigation
- **Code blocks** with syntax highlighting
- **Cross-references** between docs

### Organization
- **Progressive disclosure**: Simple → Complex
- **Task-oriented**: "How do I..." format
- **Examples first**: Show, then explain
- **Troubleshooting included**: Common issues addressed

### Maintenance
- **Date stamps** in test reports
- **Version info** in configurations
- **Status indicators** (✅/❌/⚠️)
- **Regular updates** after changes

## Contributing to Docs

When updating documentation:

1. **Update related docs** - Changes may affect multiple files
2. **Test examples** - Verify all code examples work
3. **Check cross-references** - Update links if files move
4. **Follow style** - Match existing formatting
5. **Add timestamps** - Note when last updated

## File Organization

```
docs/
├── README.md           # This file - overview and navigation
├── quick-start.md      # 30-second testing guide
├── testing-guide.md    # Complete testing methodology
├── test-report.md      # Detailed test results
└── reference.md        # Quick reference card
```

## Related Directories

- `../tests/` - Automated test scripts
- `../scripts/` - Utility and test runner scripts
- `../` - Plugin source code

## Need Help?

1. Read the [quick-start.md](quick-start.md)
2. Check [testing-guide.md](testing-guide.md) troubleshooting
3. Review [test-report.md](test-report.md) expected behavior
4. Run the interactive test: `bash ../scripts/run_tests.sh`

---

**Last Updated:** 2025-10-31
**Plugin Version:** Compatible with Mistral Codestral latest
**Neovim Version:** 0.9.0+
