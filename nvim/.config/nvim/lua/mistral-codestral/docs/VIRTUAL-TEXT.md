# Virtual Text Mode

GitHub Copilot-style inline suggestions that appear as gray text.

## Overview

Virtual text shows AI suggestions inline as you type, in a non-intrusive way (gray comment color).

```
def hello_world_▌
                 ↑
                 Your code here (normal)

def hello_world__test()__  ← Virtual text (gray, not real)
                   ^^^^
```

The gray text is **not inserted** until you press a key to accept it.

## How It Works

### Trigger

1. You type 3+ characters in a supported buffer
2. You stop typing and wait 800ms (idle)
3. Plugin requests completion from Mistral API
4. API responds with suggestion
5. Suggestion appears as gray text at end of line

### Accept or Dismiss

- **`<M-l>`** - Insert the suggestion (moves cursor to end)
- **`<C-Right>`** - Insert only next word
- **`<C-Down>`** - Insert only current line
- **`<C-c>`** - Clear suggestion (dismiss)
- **Move cursor** >5 characters - Automatically clears
- **Exit insert mode** - Automatically clears

## Configuration

### Enable/Disable

```lua
virtual_text = {
  enabled = true    -- Default: enabled
}
```

### Automatic vs Manual

```lua
virtual_text = {
  manual = false    -- Default: automatic (shows while you type)
  manual = true     -- Manual only: use :MistralCodestralVirtualComplete
}
```

### Response Time

```lua
virtual_text = {
  idle_delay = 800    -- Wait 800ms after last keystroke
}
-- Lower = faster but more intrusive
-- Higher = less intrusive but slower
```

### Minimum Characters

```lua
virtual_text = {
  min_chars = 3       -- Need 3+ chars in current word
}
-- The requirement applies to the word before cursor
-- Example: "return a " = 1 char ("a"), won't trigger
--          "return ab" = 2 chars ("ab"), won't trigger
--          "return abc" = 3 chars ("abc"), will trigger
```

### Key Bindings

Customize the keys to accept/dismiss suggestions:

```lua
virtual_text = {
  key_bindings = {
    accept = "<M-l>",          -- Accept full text
    accept_word = "<C-Right>", -- Accept next word
    accept_line = "<C-Down>",  -- Accept one line
    next = "<M-]>",            -- Next variant (future)
    prev = "<M-[>",            -- Prev variant (future)
    clear = "<C-c>",           -- Clear suggestion
  }
}
```

Set to `false` or empty string to disable a binding:

```lua
virtual_text = {
  key_bindings = {
    accept = "<M-l>",
    accept_word = false,       -- Disable accept_word
    clear = "<C-c>",
  }
}
```

## Status Line Integration

Show completion status in your status line.

```lua
-- Get status string like "1/1" or " * " (waiting)
local status_str = require("mistral-codestral.virtual_text").status_string()

-- Use in your status line config
-- Example for lualine:
{
  function()
    return require("mistral-codestral.virtual_text").status_string()
  end,
  color = { fg = "#999999" }
}
```

Status meanings:
- `   ` (spaces) - No active completion
- ` * ` - Waiting for API response
- `1/1` - Showing completion 1 of 1
- `2/3` - Showing completion 2 of 3

## When Virtual Text Appears

Virtual text triggers in these conditions:

✅ **Will show:**
- In supported file types (lua, python, javascript, etc.)
- After typing 3+ characters (configurable)
- After 800ms idle (configurable)
- When not in excluded buffers
- When API key is valid

❌ **Won't show:**
- In help buffers
- In plugin windows (neo-tree, lazy, telescope, etc.)
- In terminal/quickfix/prompt buffers
- When typing less than min_chars
- When buffer is globally excluded

## Examples

### Example 1: JavaScript Function

```javascript
function sum(a, b) {
  return▌
         ↑ cursor
```

Type "a +" and wait:

```javascript
function sum(a, b) {
  return a +__b__
            ^^^^^^^^ gray virtual text (not inserted yet)
```

Press `<M-l>`:

```javascript
function sum(a, b) {
  return a + b▌
             ↑ cursor moved here
```

### Example 2: Python List Comprehension

```python
numbers = [1, 2, 3]
doubled = [▌
           ↑ cursor
```

Type "x * 2" and wait:

```python
numbers = [1, 2, 3]
doubled = [x * 2__ for x in numbers]__
                    ^^^^^^^^^^^^^^^^^^^^ gray virtual text
```

Press `<C-Down>` (accept line) to insert only first line:

```python
numbers = [1, 2, 3]
doubled = [x * 2▌
             ↑ cursor
```

## Keyboard Shortcuts

### Accept Commands

| Key | Action | Use Case |
|-----|--------|----------|
| `<M-l>` | Accept full suggestion | Accept all lines |
| `<C-Right>` | Accept next word | Accept one word |
| `<C-Down>` | Accept current line | Accept one line |

### Other

| Key | Action |
|-----|--------|
| `<C-c>` | Clear (dismiss) |
| Move cursor | Clears automatically if >5 chars away |
| Exit insert | Clears automatically |

## Prefix Matching

The plugin avoids showing duplicate text.

```
Scenario:
  You type: "return hello_"
  API suggests: "_world()"

Plugin shows: "world()" ← removes duplicate "_"
              (not "__world()")

Screen: "return hello_world()"  ← looks natural
                    ^^^^^^^^ gray virtual text
```

This matching prevents the confusing double characters that might occur.

## Troubleshooting

### Virtual text not appearing

**Check these in order:**

1. **Is it enabled?**
   ```lua
   virtual_text = { enabled = true }
   ```

2. **Did you type 3+ characters?**
   - Type at least 3 characters in current word
   - "ab" won't work, "abc" will

3. **Did you wait 800ms?**
   - Stop typing and count to 1
   - Virtual text should appear

4. **Is buffer excluded?**
   ```bash
   :lua print(require("mistral-codestral").is_buffer_excluded())
   ```
   - Should print `false`
   - If `true`, buffer is excluded

5. **Is API key valid?**
   ```bash
   :MistralCodestralAuth status
   ```

6. **Check debug output:**
   ```lua
   -- Enable debug logging
   debug = true

   -- Check :messages for logs
   :messages
   ```

### Virtual text appears but won't accept

If pressing `<M-l>` doesn't work:

1. Check key isn't bound to something else
   ```bash
   :verbose imap <M-l>
   ```

2. Check it's the right mode (insert mode only)
   - Use `i` to enter insert mode first
   - Virtual text only works in insert

3. Try with explicit accept command:
   ```bash
   :MistralCodestralVirtualComplete
   ```

### Virtual text disappears too quickly

If suggestion clears before you can accept:

1. Increase `idle_delay`:
   ```lua
   virtual_text = { idle_delay = 1500 }  -- 1.5 seconds instead of 0.8
   ```

2. Don't move cursor - even 5 chars movement clears it
   - Use `<C-Right>` or `<C-Down>` to move cursor within suggestion

### Duplicate text showing

Example showing `world_world` instead of just `world`:

This shouldn't happen - prefix matching removes duplicates. If you see this:

1. File a bug report
2. As workaround, disable virtual text temporarily:
   ```bash
   :MistralCodestralToggle
   ```

## Performance Tips

### Faster Feedback

Reduce delay for quicker suggestions:

```lua
virtual_text = {
  idle_delay = 200,    -- 200ms instead of 800ms
  min_chars = 1,       -- Show for single chars
}
```

**Trade-off**: More intrusive (suggestions pop up while you're still typing)

### Less Intrusive

Increase delay to be less disruptive:

```lua
virtual_text = {
  idle_delay = 1500,   -- 1.5 seconds
  min_chars = 5,       -- Only for longer words
}
```

**Trade-off**: Slower feedback

### Disable in Slow Files

Large files with slow LSP can cause lag. Exclude them:

```lua
exclusions = {
  buffer_patterns = {
    "^huge_legacy_file",  -- Don't trigger in this file
  }
}
```

## Advanced: Manual Mode

If you prefer to request completions manually:

```lua
virtual_text = {
  enabled = true,
  manual = true,  -- Don't auto-trigger
}
```

Then use command to manually trigger:

```bash
:MistralCodestralVirtualComplete  " Request suggestion
:MistralCodestralVirtualClear     " Clear suggestion
```

Or create keybindings:

```lua
vim.keymap.set("i", "<M-Enter>", function()
  require("mistral-codestral.virtual_text").complete()
end)

vim.keymap.set("i", "<M-Escape>", function()
  require("mistral-codestral.virtual_text").clear_virtual_text()
end)
```

## Highlight Customization

Virtual text uses the `Comment` highlight group (gray by default).

Customize the color:

```lua
-- Neovim
vim.cmd("highlight MistralVirtualText ctermfg=8 guifg=#808080")

-- Or in your colorscheme:
vim.api.nvim_set_hl(0, "Comment", { fg = "#808080", italic = true })
```

## How It Compares

### vs GitHub Copilot

| Feature | Mistral | Copilot |
|---------|---------|---------|
| Inline display | ✓ | ✓ |
| Gray color | ✓ | ✓ |
| Accept/dismiss | ✓ | ✓ |
| Cycle variants | Planned | ✓ |
| Tab to accept | Configurable | Yes |

### vs Completion Menus

| Feature | Virtual Text | Menu |
|---------|-------------|------|
| Always visible | No, waits for idle | Yes, on demand |
| Clean UI | ✓ | ✓ |
| Multiple options | Planned | ✓ |
| LSP priority | No | Yes |

---

See [CONFIGURATION.md](CONFIGURATION.md) for all config options.
See [ARCHITECTURE.md](ARCHITECTURE.md) for technical details.
