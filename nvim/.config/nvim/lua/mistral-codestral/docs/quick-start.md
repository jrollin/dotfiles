# Quick Start - Test Mistral Autocomplete in 30 Seconds

## Option 1: Interactive Visual Test (Best for First Time)

Run this command:
```bash
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh
```

This gives you a menu with options to:
1. Test with JavaScript
2. Test with Python
3. Run automated verification
4. Check configuration

---

## Option 2: One-Command Test

### Test JavaScript Autocomplete:
```bash
echo 'function sum(a,b){return ' > /tmp/quick.js && nvim /tmp/quick.js
```

**What to do:**
1. Neovim opens
2. Press `i` to insert mode
3. Move cursor to end of line (after "return ")
4. Wait 1 second
5. See completion menu with 󰭶 icon

---

## Option 3: Super Quick API Test

Just check if Mistral API responds:
```bash
nvim --headless -u ~/.config/nvim/init.lua -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1 | grep "✓"
```

Should show:
```
✓ Result: a + b;
✓ Result: map((number) => number * 2);
```

---

## Option 4: Check Everything is Working

```bash
nvim --headless -u ~/.config/nvim/init.lua -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

Should show:
```
✓ Plugin initialization
✓ Blink.cmp integration
✓ API key authentication
... (all tests passing)
```

---

## What You Should See When Testing Manually

When you type code and wait for autocomplete:

```
┌─────────────────────────────────────┐
│ Your code here [cursor]             │
│                                     │
│ ┌── Completion Menu ──────────────┐ │
│ │ 󰊕 suggestion 1         LSP     │ │  ← LSP first
│ │ 󰊕 suggestion 2         LSP     │ │
│ │ 󰜉 path/to/file         Path    │ │
│ │ 󰭶 AI suggestion        Mistral │ │  ← Mistral here!
│ │ 󰦨 buffer_word          Buffer  │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

The **󰭶 icon** means it's a Mistral AI suggestion!

---

## Keyboard Shortcuts During Test

While completion menu is open:
- `<Tab>` or `<CR>` - Accept selected completion
- `<C-n>` - Next item
- `<C-p>` - Previous item
- `<Esc>` - Cancel

Manual trigger:
- `<leader>mc` - Force Mistral completion (usually `,mc` or `\mc`)

---

## Troubleshooting One-Liners

**Check API key:**
```bash
nvim --headless -u ~/.config/nvim/init.lua -c "lua print(require('mistral-codestral.auth').get_api_key() and 'OK' or 'NO KEY')" -c qa 2>&1
```

**Check blink.cmp has Mistral source:**
```bash
nvim --headless -u ~/.config/nvim/init.lua -c "lua print(require('blink.cmp').config.sources.providers.mistral_codestral and 'OK' or 'NOT REGISTERED')" -c qa 2>&1
```

**Verify buffer not excluded:**
```bash
nvim --headless -u ~/.config/nvim/init.lua -c "edit /tmp/test.js" -c "lua print(require('mistral-codestral').is_buffer_excluded() and 'EXCLUDED' or 'OK')" -c qa 2>&1
```

---

## Most Common Issues

### "I don't see Mistral completions"

1. **Did you type 3+ characters?**
   - Requirement: minimum 3 characters

2. **Did you wait 800ms?**
   - Delay is intentional to not be intrusive

3. **Is LSP providing completions?**
   - Mistral has LOWER priority than LSP
   - This is correct! LSP should come first

4. **Try manual trigger:**
   - Press `<leader>mc` to force Mistral

### "Completions are slow"

This is expected:
- API call to Mistral takes 1-3 seconds
- Timeout is set to 2000ms
- This prevents blocking your typing

### "Only see LSP, not Mistral"

This is **correct behavior**!
- LSP has higher priority
- Mistral appears below LSP items
- Look for the 󰭶 icon in the menu

---

## Simple Test Right Now

Copy and paste this entire block:

```bash
cat > /tmp/test_now.js << 'EOF'
function multiply(a, b) {
  return
}
EOF

nvim /tmp/test_now.js
```

Then:
1. Press `A` (append at end of return line)
2. Type a space
3. Wait 1-2 seconds
4. Look for completion menu

You should see Mistral suggest `a * b` or similar!

---

## Documentation Reference

Full testing guide: `~/.config/nvim/lua/mistral-codestral/docs/testing-guide.md`
Test summary: `~/.config/nvim/lua/mistral-codestral/docs/test-report.md`
Quick reference: `~/.config/nvim/lua/mistral-codestral/docs/reference.md`

---

**TL;DR: Run this to test interactively:**
```bash
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh
```

**Or this for quick verification:**
```bash
nvim --headless -u ~/.config/nvim/init.lua -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```
