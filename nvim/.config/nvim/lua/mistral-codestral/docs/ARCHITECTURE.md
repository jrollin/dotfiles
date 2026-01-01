# Architecture & How It Works

Complete technical documentation of the Mistral Codestral plugin architecture.

## Overview

The plugin provides AI code completions through three independent mechanisms:

1. **Virtual Text** - Inline suggestions (GitHub Copilot-style)
2. **Completion Menus** - Integration with blink.cmp or nvim-cmp
3. **Manual Trigger** - On-demand via command or keybinding

Each mechanism shares the same context extraction and API request logic but displays results differently.

## Component Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    mistral-codestral.nvim                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │            init.lua (Main Module)                │  │
│  │  • Configuration management                      │  │
│  │  • Context extraction (FIM)                      │  │
│  │  • HTTP requests to Mistral API                  │  │
│  │  • Completion insertion                          │  │
│  └──────────────────────────────────────────────────┘  │
│                         ▲                               │
│        ┌────────────────┼────────────────┐             │
│        │                │                │             │
│  ┌──────────────┐ ┌────────────────┐ ┌──────────────┐ │
│  │ virtual_text │ │  blink.lua     │ │ cmp_source   │ │
│  │              │ │  (blink.cmp)   │ │ (nvim-cmp)   │ │
│  │ • Display    │ │  • Integrate   │ │ • Register   │ │
│  │ • Navigation │ │  • Format      │ │ • Format     │ │
│  │ • Keybinds   │ │  • Cache       │ │ • Autoconfig │ │
│  └──────────────┘ └────────────────┘ └──────────────┘ │
│        ▲                ▲                    ▲         │
│        └────────────────┼────────────────────┘         │
│                         │                              │
│                    ┌────┴─────┐                        │
│                    │           │                       │
│              ┌──────────┐  ┌──────────────┐            │
│              │ auth.lua │  │ http_client  │            │
│              │          │  │              │            │
│              │ • Keys   │  │ • POST reqs  │            │
│              │ • Cache  │  │ • Auth       │            │
│              │ • Validate   │ • Error hdl  │            │
│              └──────────┘  └──────────────┘            │
│                    │           │                       │
│                    └───────┬───┘                       │
│                            │                           │
│                  ┌─────────┴─────────┐                │
│                  │ lsp_utils.lua     │                │
│                  │ • Diagnostics     │                │
│                  │ • Symbols         │                │
│                  │ • Hover info      │                │
│                  │ • Treesitter      │                │
│                  └───────────────────┘                │
│                                                       │
└─────────────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌─────────────┐  ┌──────────┐  ┌──────────────┐
    │ Mistral API │  │ blink.cmp│  │  nvim-cmp   │
    └─────────────┘  └──────────┘  └──────────────┘
```

## Virtual Text Flow

How inline suggestions appear while you type.

### Trigger Phase (User Types)

```lua
User in INSERT mode
  │
  └─→ TextChangedI autocmd
      │
      ├─ Check: Buffer excluded? → Exit
      ├─ Check: Filetype excluded? → Exit
      ├─ Check: min_chars requirement met? → Exit if not
      │
      └─→ M.debounced_complete()
          │
          ├─ Cancel old timer (if exists)
          └─ Start NEW timer: 800ms delay
```

**Key insight**: Timer resets on every keystroke. Only fires after 800ms silence.

### Request Phase (After Delay)

```lua
Timer expires
  │
  └─→ request_virtual_completions()
      │
      ├─ Check: Already waiting? → Exit
      │
      ├─ Set status.state = "waiting"
      │
      ├─ Get enhanced context
      │  ├─ prefix (code before cursor)
      │  ├─ suffix (code after cursor)
      │  ├─ LSP diagnostics
      │  ├─ Current function/class
      │  └─ Imports
      │
      └─→ mistral.request_completion()
          │
          └─→ HTTP POST to Mistral API (async)
              └─→ Callback fires when response arrives
```

### Response Phase (API Responds)

```lua
Mistral API returns completion
  │
  └─→ Callback invoked
      │
      ├─ Check: Empty response? → Clear and exit
      │
      ├─ Store in current_completions = {completion}
      │
      ├─ Set status.state = "completions"
      │
      └─→ show_virtual_text(completion, row, col)
          │
          ├─ Split completion into lines
          ├─ Validate prefix match (avoid duplication)
          ├─ Create extmarks with virtual text
          └─ Render as gray comment text at EOL
```

### Cleanup Phase (User Accepts or Moves)

```lua
User presses <M-l> (accept)
  │
  └─→ M.accept()
      │
      ├─ Validate buffer still same
      ├─ Apply prefix matching again
      ├─ clear_virtual_text()
      └─→ mistral_module.insert_completion(text)
          └─ Actual text inserted into buffer

         OR

User moves cursor >5 chars or changes line
  │
  └─→ CursorMovedI autocmd
      │
      └─→ clear_virtual_text()
          │
          ├─ Stop timer
          ├─ Clear all extmarks
          ├─ Reset state
          └─ No text inserted
```

## Prefix Matching Logic

Avoids showing duplicate text you've already typed.

```lua
Example:
  current_line = "def hello_world"
  cursor_col = 10 (after "hello_")
  completion = "world_test()"

Step 1: Check overlap after cursor
  line_after = "world"
  completion starts with "world" → remove it
  completion = "_test()"

Step 2: Check prefix match before cursor
  line_before = "def hello_"
  "_" from completion matches suffix of line_before
  matching_prefix = 1

Step 3: Final result
  display = "_test()"[2:] = "test()"

Screen shows: "def hello_world_test()"  ← only "test()" is gray virtual text
```

## Completion Menu Flow (blink.cmp)

How completions appear in the selection menu.

### Trigger

```lua
User triggers completion in blink.cmp
  │
  └─→ BlinkSource:get_completions(context, callback)
      │
      ├─ Check: enabled? → Return empty if not
      ├─ Check: buffer excluded? → Return empty if yes
      │
      ├─ Generate cache key from context
      ├─ Check cache (5 sec TTL)
      │  └─ If hit: Return cached items → Done
      │
      ├─ Get enhanced LSP context
      │
      ├─ Determine strategy (normal/comment/function_body)
      │
      └─→ mistral.request_completion(context)
          └─→ Async HTTP POST to API
              └─→ Callback creates items
```

### Item Creation

```lua
Completion received
  │
  └─→ M.create_blink_items(completion, context, strategy)
      │
      ├─ Split into lines
      │
      ├─ Main item (full completion)
      │  ├─ label: First 60 chars + "..." if multi-line
      │  ├─ sortText: "50_" = lower priority
      │  └─ score_offset: 10 (below LSP)
      │
      ├─ IF multi-line AND room in menu:
      │  ├─ First-line variant (sortText: "51_")
      │  └─ Two-lines variant (sortText: "52_")
      │
      └─→ Return items array to blink.cmp
          └─→ Items appear in completion menu
```

**Priority**: Sort text "50_" places it below LSP ("00_") intentionally.

## Context Extraction (get_fim_context_enhanced)

How the plugin understands your code.

```lua
get_fim_context_enhanced()
  │
  ├─ Get current buffer, cursor position
  │
  ├─ Read all buffer lines
  │
  ├─ Calculate smart context window
  │  ├─ Not more than 100 lines
  │  ├─ Not less than 20 lines
  │  └─ ~1/4 of file size
  │
  ├─ Build prefix (lines before cursor + partial current line)
  │
  ├─ Build suffix (partial current line + lines after)
  │
  ├─ Get filetype (from buffer or LSP)
  │
  ├─ Find workspace root (via LSP or fallback)
  │
  └─→ Return:
      {
        prefix = "...",
        suffix = "...",
        filetype = "lua",
        relative_path = "init.lua",
        workspace_root = "/home/user/project"
      }
```

### Enhanced Context (with LSP)

```lua
lsp_utils.get_enhanced_context()
  │
  ├─ Get base context (from above)
  │
  ├─ Get LSP diagnostics
  │  ├─ Errors
  │  ├─ Warnings
  │  └─ Hints
  │
  ├─ Get current context
  │  ├─ In function? (name)
  │  └─ In class? (name)
  │
  ├─ Get imports at top of file
  │  └─ Language-specific pattern matching
  │
  └─→ Return augmented context
      │
      └─ prefix modified with comment headers:
         "// Imports:\nuse std::...\n\n
          // In function: process\n
          // In class: Handler\n
          <original prefix>"
```

## API Request Flow

Communication with Mistral Codestral API.

```lua
mistral.request_completion(data, callback)
  │
  ├─ Get API key from auth module
  │
  ├─ Build request payload
  │  {
  │    model = "codestral-latest",
  │    prompt = <prefix>,
  │    suffix = <suffix>,
  │    max_tokens = 256,
  │    temperature = 0.1,
  │    stop = { "\n\n" }
  │  }
  │
  └─→ http_client.post(
      url = "https://codestral.mistral.ai/v1/fim/completions",
      headers = {
        "Authorization: Bearer <api_key>",
        "Content-Type: application/json"
      },
      data = payload,
      timeout = 10000ms
    )
    │
    └─→ Async HTTP call (non-blocking)
        │
        ├─ On success:
        │  └─→ Parse JSON response
        │     └─→ Extract completion from choices[0].text
        │        └─→ callback(completion, nil)
        │
        └─ On error:
           └─→ callback(nil, error_message)
```

## Caching Strategy

Reduces redundant API calls.

### Cache Key Generation

```lua
For virtual text:
  key = SHA256(prefix_last_200 + "|" + suffix_first_200 + "|" + filetype + "|" + cursor_row + "," + cursor_col)

For completion menu:
  key = SHA256(prefix_last_200 + "|" + suffix_first_200 + "|" + filetype + "|" + reason)
```

### Cache Behavior

```lua
Cache timeout = 5 seconds

Scenario:
  T=0ms:   User types → request sent
  T=100ms: API responds → result cached
  T=200ms: User types same thing → cached result returned instantly
  T=300ms: Same → cached result returned
  T=5100ms: Cache expires → fresh request sent
```

## State Management

Plugin state tracking across completions.

### Virtual Text Status

```lua
status = {
  state = "idle" | "waiting" | "completions",
  current = 1,              -- Which completion variant displayed
  total = 1,                -- Total variants available
  completion_row = 10,      -- Row where shown
  completion_col = 20,      -- Col where shown
  completion_bufnr = 5      -- Buffer where shown
}
```

Used to:
- Show status in statusline
- Validate cursor hasn't moved too far
- Track which buffer completion is for
- Support cycling through variants (future)

## Buffer Exclusion Caching

Fast path for excluded buffers.

```lua
┌─────────────────────────┐
│  is_buffer_excluded()   │
├─────────────────────────┤
│                         │
│  Check cache first      │
│  ├─ If hit: return      │
│  └─ If miss: continue   │
│                         │
│  Check filetype         │
│  Check buftype          │
│  Check buffer name      │
│  Check floating window  │
│                         │
│  Cache result           │
│  Return                 │
│                         │
└─────────────────────────┘

Cache invalidated on:
  • BufReadPost
  • BufNewFile
  • BufWritePost
  • FileType
  • BufDelete
```

## Error Handling

How errors are handled without disrupting editing.

```lua
Safe patterns used throughout:

1. pcall() for risky operations
   local ok, result = pcall(vim.api.xxx)
   if not ok then handle_error() end

2. Try-catch for Lua errors
   local ok, err = pcall(risky_fn)
   if not ok then log_error(err) end

3. Validation before use
   if not completion or completion == "" then
     return  -- Silent exit
   end

4. Fallback values
   local filetype = vim.bo.filetype or "unknown"

5. Non-blocking callbacks
   Everything async via callbacks
   Timeouts prevent hanging
```

## Performance Optimizations

How the plugin stays fast.

1. **Caching** - 5 second TTL prevents repeated API calls
2. **Debouncing** - Wait 800ms after typing before requesting
3. **Lazy module loading** - Load only when needed
4. **Exclusion cache** - Avoid repeated checks for excluded buffers
5. **LSP client cache** - Cache client list for 100ms
6. **Context window sizing** - Smart sizing based on file size
7. **Async-first** - All API calls non-blocking
8. **Early returns** - Exit fast when conditions not met

## Integration Points

### With blink.cmp

```lua
blink.cmp calls BlinkSource:get_completions()
  │
  ├─ We return blink-formatted items
  │  ├─ label
  │  ├─ insertText
  │  ├─ kind (Snippet or Text)
  │  ├─ detail
  │  ├─ documentation
  │  └─ sortText
  │
  └─ blink.cmp handles display and selection
```

### With nvim-cmp

```lua
nvim-cmp calls source:complete()
  │
  ├─ We return cmp-formatted items
  │  ├─ label
  │  ├─ insertText
  │  ├─ kind (CompletionItemKind)
  │  ├─ detail
  │  └─ documentation
  │
  └─ nvim-cmp handles display and selection
```

### With LSP

```lua
We call vim.lsp.get_active_clients()
  │
  ├─ Get diagnostics
  ├─ Get symbols
  ├─ Get hover information
  │
  └─ Use for enhanced context in completions
```

### With Treesitter

```lua
If available, we use it to detect:
  ├─ In comment
  ├─ In string
  ├─ In function
  └─ In class

For strategy selection
```

## Threading Model

All operations non-blocking.

```lua
Main Neovim thread
  │
  ├─ TextChangedI event → Queue timer (return immediately)
  ├─ Timer fires → Queue HTTP request (return immediately)
  └─ HTTP response → Callback scheduled via vim.schedule()
      └─ Callback runs next iteration of event loop
         └─ Update buffer/state (blocking but short)
```

This ensures typing always remains responsive.

## Summary

The plugin architecture emphasizes:

1. **Non-blocking** - Async everywhere, never blocks typing
2. **Failsafe** - Errors don't crash editor or interrupt flow
3. **Fast** - Caching and debouncing reduce latency
4. **Flexible** - Multiple display modes (virtual text, menus, manual)
5. **Smart** - Context-aware with LSP integration
6. **Configurable** - Fine-grained control over behavior

See [CONFIGURATION.md](CONFIGURATION.md) for tuning options.
See [VIRTUAL-TEXT.md](VIRTUAL-TEXT.md) for virtual text specifics.
See [COMPLETION-ENGINES.md](COMPLETION-ENGINES.md) for menu integration details.
