# Mistral Codestral Plugin - Quick Reference

## ✅ Test Status: ALL PASSED

### Configuration Summary
```
Location: .config/nvim/lua/mistral-codestral/
API Key: ✓ Valid (32 chars, loaded from ~/.mistral_codestral_key)
Model: codestral-latest
Engine: blink.cmp
Status: Production Ready
```

### Completion Settings
- **Trigger**: Automatic after 3+ characters
- **Delay**: 800ms idle time
- **Timeout**: 2000ms max
- **Priority**: Below LSP and snippets (-50 offset)
- **Max items**: 1 (to avoid menu clutter)

### Key Bindings
| Key | Action |
|-----|--------|
| `<leader>mc` | Force Mistral completion |
| `<leader>ma` | Check authentication status |
| `<Tab>` | Accept completion/snippet |
| `<C-Right>` | Accept word (virtual text) |
| `<C-Down>` | Accept line (virtual text) |
| `<C-c>` | Clear suggestion |

### Commands
```vim
:MistralCodestralComplete    " Get code completion
:MistralCodestralToggle      " Enable/disable completions
:MistralCodestralAuth status " Check API key status
:MistralCodestralAuth set    " Set new API key
:MistralCodestralAuth validate " Validate current key
```

### Tested Languages
- ✓ JavaScript (functions, arrays, objects, async)
- ✓ Python (functions, classes, list comprehensions)

### Completion Priority Order
1. **LSP** - Highest priority, language server completions
2. **Path** - File path completions
3. **Snippets** - Code snippets from friendly-snippets
4. **Mistral Codestral** - AI-powered suggestions (󰭶 icon)
5. **Buffer** - Words from current buffer

### Excluded Contexts
The plugin won't trigger in:
- Help buffers
- Plugin windows (neo-tree, lazy, mason, etc.)
- Terminal buffers
- Quickfix lists
- Prompt buffers

### Integration Status
| System | Status | Notes |
|--------|--------|-------|
| Blink.cmp | ✓ Working | Registered as provider |
| LSP | ✓ Compatible | No interference |
| Snippets | ✓ Compatible | Tab key works for both |
| Virtual Text | ✓ Configured | 800ms delay, 3 char min |

### Performance Notes
- 2 second timeout prevents hanging
- 3 character minimum reduces API calls
- Single item limit prevents menu dominance
- Negative score keeps LSP suggestions first

### Example Usage

**JavaScript:**
```javascript
function sum(a, b) {
  return  // Type here, Mistral suggests: a + b;
}

const numbers = [1, 2, 3];
const doubled = numbers. // Suggests: map((n) => n * 2);
```

**Python:**
```python
def sum(a, b):
    return  # Suggests: a + b

numbers = [1, 2, 3]
squared = [ # Suggests: num ** 2 for num in numbers
```

### Troubleshooting

**No completions appearing?**
1. Check you've typed 3+ characters
2. Wait 800ms for trigger
3. Verify API key: `<leader>ma`
4. Check buffer isn't excluded: `:lua print(require('mistral-codestral').is_buffer_excluded())`

**Completions too slow?**
- Reduce timeout in `.config/nvim/lua/plugins/blink.lua`
- Lower `idle_delay` in mistral config

**Too many/few suggestions?**
- Adjust `max_items` in blink.lua (currently 1)
- Change `score_offset` for priority

### Files Modified/Created for Testing
```
/tmp/test_mistral.js          # JavaScript test file
/tmp/test_mistral.py          # Python test file
/tmp/mistral_test_summary.md  # Detailed test report
/tmp/test_*.lua               # Various test scripts
```

### Plugin Files
```
.config/nvim/lua/mistral-codestral/
├── init.lua          # Main plugin code
├── auth.lua          # Authentication management
├── blink.lua         # Blink.cmp integration
├── lsp_utils.lua     # LSP enhancement utilities
├── virtual_text.lua  # Virtual text mode
├── advanced.lua      # Advanced features
└── health.lua        # Health check

.config/nvim/lua/plugins/
├── mistral.lua       # Plugin configuration
└── blink.lua         # Blink.cmp config with Mistral source
```

---
**Last Tested:** 2025-10-31
**All Systems:** ✅ Operational
