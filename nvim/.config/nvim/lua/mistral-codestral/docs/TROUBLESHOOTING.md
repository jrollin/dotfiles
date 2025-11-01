# Troubleshooting: "I Don't See Mistral Suggestions"

## Quick Fix: The 3-Character Rule

**The most common issue**: You need to type **at least 3 characters** after "return" to trigger completions.

### ❌ This WON'T work:
```javascript
function sum(a, b) {
  return ▌  // cursor here - 0 characters typed, won't trigger
}
```

### ✅ This WILL work:
```javascript
function sum(a, b) {
  return a +▌  // typed "a +" (3+ chars), will trigger!
}
```

## Why This Happens

Your blink.cmp configuration has:
```lua
min_keyword_length = 3  -- Requires 3+ characters
```

When your cursor is right after `return ` (with a space), the "word before cursor" is **empty**. You need to **start typing** something to reach the 3-character minimum.

## Step-by-Step Test

1. **Open the test file:**
   ```bash
   nvim ~/.config/nvim/lua/mistral-codestral/tests/fixtures/step-by-step-test.js
   ```

2. **Go to Test 1 (line ~24)**
   - Position cursor after `return ` in the `sum` function
   - Press `A` to enter INSERT mode at end of line

3. **Type slowly and wait:**
   ```
   Type: "a"     → Wait (only 1 char, nothing happens)
   Type: " "     → Wait (only 2 chars, nothing happens)
   Type: "+"     → Wait 1 second
   ```
   **Now** you should see the completion menu!

4. **Look for the robot icon 󰭶**
   - This means it's a Mistral AI suggestion
   - LSP suggestions appear first (󰊕 icon)
   - Mistral appears below them

## Alternative: Use Manual Trigger

Don't want to type 3 characters? Use manual completion:

1. Position cursor where you want completion
2. Press `<leader>mc` (usually `,mc` or `\mc`)
3. Mistral will immediately request a completion

**Example:**
```javascript
function sum(a, b) {
  return ▌  // cursor here
}
```
Press `<leader>mc` → Mistral suggests: `a + b;`

## Run Diagnostics

To check what's wrong, run:

```vim
:lua require('mistral-codestral.scripts.debug_completion').diagnose()
```

Or source the file first and create a command:
```vim
:luafile ~/.config/nvim/lua/mistral-codestral/scripts/debug_completion.lua
:DiagnoseMistral
```

This will check:
- ✓ Plugin loaded?
- ✓ API key valid?
- ✓ Blink.cmp configured?
- ✓ Buffer not excluded?
- ✓ Minimum characters typed?
- ✓ API responding?

## Common Issues

### Issue 1: "I typed 3+ characters but still nothing"

**Check the wait time:**
- Idle delay: 800ms (wait after typing)
- API timeout: 2000ms (API response time)
- **Total**: Wait up to ~3 seconds after typing

**Try:**
```vim
:lua print(require('blink.cmp').config.sources.providers.mistral_codestral.timeout_ms)
```

### Issue 2: "I only see LSP completions, no Mistral"

**This is correct!** Mistral has **lower priority** than LSP by design.

Look carefully at the completion menu:
```
┌─────────────────────────┐
│ 󰊕 a          LSP       │ ← LSP first
│ 󰊕 b          LSP       │
│ 󰭶 a + b      Mistral   │ ← Mistral below (robot icon!)
└─────────────────────────┘
```

If you don't see the 󰭶 icon anywhere, then Mistral isn't triggering.

### Issue 3: "Buffer is excluded"

**Check:**
```vim
:lua print(require('mistral-codestral').is_buffer_excluded())
```

Should return `false`. If it returns `true`:

**Common excluded buffers:**
- Help buffers (`:help`)
- Plugin windows (neo-tree, lazy, mason)
- Terminal buffers
- Buffers with `buftype=nofile`

**Fix:** Use a real file:
```bash
cd /tmp
nvim test.js  # Real file, not a plugin window
```

### Issue 4: "API key issues"

**Check:**
```vim
:MistralCodestralAuth status
```

Should say: `API key is valid`

If not:
```vim
:MistralCodestralAuth set
```

Or verify the file:
```bash
cat ~/.mistral_codestral_key
```

Should contain your 32-character API key.

### Issue 5: "Plugin not loaded"

**Check:**
```vim
:lua print(require('mistral-codestral'))
```

Should show a table, not an error.

If error, check:
```vim
:Lazy
```

Find `mistral-codestral.nvim` and ensure it's loaded (green checkmark).

## Reduce Min Characters (Optional)

If you want completions with fewer characters, edit:

`.config/nvim/lua/plugins/blink.lua`

```lua
providers = {
  mistral_codestral = {
    min_keyword_length = 1,  -- Changed from 3 to 1
    -- ... rest of config
  },
}
```

Restart Neovim:
```vim
:qa
nvim test.js
```

**Warning:** Lower values = more API calls = slower/more intrusive

## Adjust Timing (Optional)

Make completions appear faster:

`.config/nvim/lua/plugins/mistral.lua`

```lua
virtual_text = {
  idle_delay = 400,  -- Changed from 800ms to 400ms
  -- ... rest of config
},
```

**Warning:** Lower delay = more frequent triggers = more API costs

## Test Everything

Run all diagnostics:
```bash
# Interactive test
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh

# API test
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1

# Full integration test
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

All tests should pass with ✓.

## Still Not Working?

1. **Check Neovim version:**
   ```vim
   :version
   ```
   Need: Neovim 0.9.0+

2. **Check blink.cmp version:**
   ```vim
   :Lazy
   ```
   Find `blink.cmp`, should be v1.6+

3. **Check logs:**
   ```vim
   :messages
   ```
   Look for Mistral-related errors

4. **Enable debug mode:**

   Edit `.config/nvim/lua/plugins/mistral.lua`:
   ```lua
   debug = true,  -- Changed from false
   ```

   Restart and watch for notifications

5. **Check network:**
   ```bash
   curl -H "Authorization: Bearer $(cat ~/.mistral_codestral_key)" \
     https://codestral.mistral.ai/v1/fim/completions
   ```
   Should not show "Unauthorized"

## Quick Reference

| Command | What it checks |
|---------|---------------|
| `:DiagnoseMistral` | Everything (after sourcing debug script) |
| `:MistralCodestralAuth status` | API key |
| `:lua print(require('mistral-codestral').is_buffer_excluded())` | Buffer exclusion |
| `:lua print(vim.inspect(require('blink.cmp').config.sources.providers.mistral_codestral))` | Blink.cmp config |
| `:messages` | Recent notifications |
| `<leader>mc` | Force completion |

## Summary

**Most likely cause:** You need to type **3+ characters** to trigger completions.

**Quick test:**
1. Open: `nvim ~/.config/nvim/lua/mistral-codestral/tests/fixtures/step-by-step-test.js`
2. Go to Test 1
3. Type: `a + ` after `return `
4. Wait 1 second
5. See completion menu with 󰭶 icon

**Still stuck?** Run diagnostics:
```vim
:luafile ~/.config/nvim/lua/mistral-codestral/scripts/debug_completion.lua
:DiagnoseMistral
```

---

**See also:**
- [testing-guide.md](testing-guide.md) - Complete testing methodology
- [quick-start.md](quick-start.md) - Quick testing commands
- [reference.md](reference.md) - Configuration reference
