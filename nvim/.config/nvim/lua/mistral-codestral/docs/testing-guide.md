# How to Test Mistral Autocomplete - Step by Step

## Method 1: Interactive Manual Testing (Recommended)

### Step 1: Open Neovim with a Test File

```bash
# Create a test JavaScript file
nvim /tmp/test_autocomplete.js
```

### Step 2: Enter Insert Mode and Type Code

Press `i` to enter insert mode, then type:

```javascript
function calculateSum(a, b) {
  return
```

**Stop typing after "return " and wait 800ms**

You should see:
- Blink.cmp completion menu appears
- LSP suggestions (if available)
- Mistral suggestion with 󰭶 icon (AI robot)
- Example: `a + b;`

### Step 3: Test Array Methods

Clear the buffer (`:1,$d`) and type:

```javascript
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.
```

**Stop after the dot and wait**

Expected Mistral suggestion: `map((n) => n * 2)`

### Step 4: Test Python

```bash
# Open Python file
nvim /tmp/test_autocomplete.py
```

Type:

```python
def add_numbers(a, b):
    return
```

**Stop and wait for suggestions**

### Step 5: Force Manual Completion

If automatic completion doesn't trigger:

1. Position cursor where you want completion
2. Press `<leader>mc` (usually `,mc` or `\mc`)
3. Mistral will force a completion request

### Step 6: Check What's Happening

Open the Neovim command line and check:

```vim
:lua print(vim.inspect(require('mistral-codestral').config()))
:lua print(require('mistral-codestral').is_buffer_excluded())
:MistralCodestralAuth status
```

---

## Method 2: Automated Testing Scripts

### Quick API Test

```bash
# Test that API is responding
nvim --headless -u ~/.config/nvim/init.lua -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1
```

### Full Integration Test

```bash
# Run all integration tests
nvim --headless -u ~/.config/nvim/init.lua -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

### Interactive Test Runner

```bash
# Run the interactive test menu
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh
```

---

## Method 3: Visual Verification in Real Neovim

### Step-by-Step Visual Test

#### 1. Start Neovim
```bash
cd /tmp
nvim test_visual.js
```

#### 2. Enter Insert Mode
Press `i`

#### 3. Type This Exact Code Slowly:

```javascript
function fibonacci(n) {
  if (n <= 1) return n;
  return
```

#### 4. What You Should See:

After typing "return " and waiting ~1 second:

```
┌─────────────────────────────────────┐
│ return [cursor]                     │
│ ┌─────────────────────────────────┐ │
│ │ 󰊕 n                        LSP  │ │
│ │ 󰊕 fibonacci               LSP  │ │
│ │ 󰭶 fibonacci(n - 1) + ...  Mistral│ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

The 󰭶 icon indicates Mistral completion!

#### 5. Navigate and Accept

- Use `<Tab>` or `<CR>` to accept
- Use `<C-n>`/`<C-p>` to navigate
- Use `<Esc>` to cancel

---

## Method 4: Debug Mode Testing

### Enable Debug Output

Edit `.config/nvim/lua/plugins/mistral.lua` and change:

```lua
debug = true,  -- Changed from false
```

Then restart Neovim:

```bash
nvim /tmp/test_debug.js
```

You'll see notifications like:
- "Mistral Codestral loaded successfully"
- "Buffer excluded/included" messages
- API request/response info

### Watch for Notifications

Type some code and watch bottom-right for:
- API call status
- Completion received/failed
- Any errors

---

## Method 5: Live Blink.cmp Menu Inspection

### While Completion Menu is Open:

1. Trigger completion (type 3+ chars)
2. When menu appears, check:
   - **Icon column**: Look for 󰭶 (Mistral) vs 󰊕 (LSP)
   - **Source label**: "Mistral" or "mistral_codestral"
   - **Position**: Should be below LSP items

### Verify Source Priority

Type something that LSP knows about:

```javascript
console.
```

LSP completions (log, error, warn) should appear FIRST.
Mistral should appear AFTER if it has suggestions.

---

## Method 6: Check Blink.cmp Configuration

### Verify Mistral is Registered

```vim
:lua print(vim.inspect(require('blink.cmp').config.sources))
```

Look for `mistral_codestral` in the providers list.

### Check Provider Status

```vim
:lua local sources = require('blink.cmp').config.sources.providers
:lua print(vim.inspect(sources.mistral_codestral))
```

Should show:
```lua
{
  enabled = true,
  async = true,
  timeout_ms = 2000,
  max_items = 1,
  score_offset = -50,
  ...
}
```

---

## Method 7: Real-World Testing Scenarios

### Scenario 1: React Component

```javascript
import React from 'react';

function MyComponent() {
  const [count, setCount] = React.useState(0);

  const handleClick = () => {
    // Type here and wait

  }

  return (
```

**Expected**: Mistral suggests JSX structure or setCount usage

### Scenario 2: Python Class

```python
class Calculator:
    def __init__(self, initial=0):
        # Type here


    def add(self, x):
        # Type here
```

**Expected**: Mistral suggests `self.value = initial` or similar

### Scenario 3: Error Handling

```javascript
async function fetchData(url) {
  try {
    const response = await fetch(url);
    // Type here

  } catch (error) {
    // Type here
```

**Expected**: Mistral suggests response handling and error logging

---

## Troubleshooting Your Tests

### Problem: No Completions Appear

**Check 1: Minimum Characters**
```vim
:lua print(require('blink.cmp').config.sources.providers.mistral_codestral.min_keyword_length)
```
Should be `3`. Make sure you type 3+ characters.

**Check 2: Buffer Not Excluded**
```vim
:lua print(require('mistral-codestral').is_buffer_excluded())
```
Should return `false`. If `true`, check filetype:
```vim
:set filetype?
```

**Check 3: API Key Valid**
```vim
:MistralCodestralAuth status
```
Should say "API key is valid"

**Check 4: Blink.cmp Running**
```vim
:lua print(package.loaded['blink.cmp'] ~= nil)
```
Should be `true`

### Problem: Only LSP Completions Show

This is actually **correct behavior**! Mistral has lower priority.

To verify Mistral is working:
1. Type in a context where LSP has no suggestions
2. Or use manual trigger: `<leader>mc`
3. Check the completion menu has the 󰭶 icon

### Problem: Completions Too Slow

**Check timeout:**
```vim
:lua print(require('blink.cmp').config.sources.providers.mistral_codestral.timeout_ms)
```

Reduce if needed in `.config/nvim/lua/plugins/blink.lua`:
```lua
timeout_ms = 1000,  -- Faster but might cut off some requests
```

---

## Expected Behavior Summary

### ✅ What Should Happen:
1. Type 3+ characters
2. Wait ~800ms
3. Completion menu appears with:
   - LSP items first (if available)
   - Path/snippet items
   - Mistral item with 󰭶 icon (max 1 item)
   - Buffer items last
4. Can accept with `<Tab>` or `<CR>`

### ❌ What Should NOT Happen:
- Mistral dominating the completion menu
- Completions in help buffers
- Completions in plugin windows (neo-tree, lazy, etc.)
- Mistral suggestions appearing before LSP

---

## Quick Reference: Test Commands

```vim
" Check if working
:MistralCodestralAuth status

" Force completion
:MistralCodestralComplete
" Or: <leader>mc

" Toggle on/off
:MistralCodestralToggle

" Check buffer exclusion
:lua print(require('mistral-codestral').is_buffer_excluded())

" View config
:lua print(vim.inspect(require('mistral-codestral').config()))

" Check last completion context
:lua print(vim.inspect(require('mistral-codestral').get_fim_context_enhanced()))
```

---

## Recording a Test Session

Want to capture what happens? Use this script:

```bash
#!/bin/bash
# save as: /tmp/test_mistral_session.sh

cat > /tmp/test_session.js << 'EOF'
// Test 1: Simple function
function sum(a, b) {
  return
}

// Test 2: Array method
const nums = [1, 2, 3];
const doubled = nums.

// Test 3: Object
const user = {
  name: "test",
  greet() {

  }
}
EOF

echo "Opening test file in Neovim..."
echo "Try typing at the marked locations and observe completions"
nvim /tmp/test_session.js
```

Run it:
```bash
chmod +x /tmp/test_mistral_session.sh
/tmp/test_mistral_session.sh
```

---

## Video-Style Testing (Terminal Recording)

Want to record your test?

```bash
# Install asciinema if needed
# Then record:
asciinema rec /tmp/mistral_test.cast

# Start neovim and test
nvim /tmp/test_autocomplete.js

# Type code, show completions
# Press Ctrl+D when done

# Play back:
asciinema play /tmp/mistral_test.cast
```

---

## Final Checklist

Before testing, verify:
- [ ] Neovim config loaded: `nvim --version`
- [ ] API key present: `cat ~/.mistral_codestral_key | wc -c` (should be ~32)
- [ ] Blink.cmp installed: `:Lazy` and check for "blink.cmp"
- [ ] Mistral plugin loaded: `:lua print(require('mistral-codestral'))`
- [ ] File type supported: `:set filetype?` (should be js, py, lua, etc.)

Now you're ready to test! Start with Method 1 (manual testing) for best results.

---

## See Also

- [Quick Start Guide](quick-start.md) - Get started in 30 seconds
- [Test Report](test-report.md) - Detailed test results
- [Reference](reference.md) - Command and configuration reference
