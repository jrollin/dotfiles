---
name: agent-browser
description: when asking to check ui or tests automation in browser
---

# Browser Automation with agent-browser

Use `agent-browser` CLI for browser automation tasks: UI checks, form testing, screenshots, visual diffs.

Requires: `npm install -g agent-browser && agent-browser install`

## Screenshots directory

Save screenshots, PDFs and diffs to `.claude/local/screenshots/` (unversioned via `.claude/` gitignore).
Create the directory before first use: `mkdir -p .claude/local/screenshots`

```bash
agent-browser screenshot .claude/local/screenshots/page.png
agent-browser pdf .claude/local/screenshots/page.pdf
agent-browser diff screenshot --baseline .claude/local/screenshots/before.png -o .claude/local/screenshots/diff.png
```

## Core workflow

1. Navigate: `agent-browser open <url>`
2. Snapshot: `agent-browser snapshot` (returns elements with refs like `@e1`, `@e2`)
3. Interact using `@refs` from the snapshot
4. Re-snapshot after navigation or significant DOM changes
5. Close: `agent-browser close`

## Commands

### Navigation

```bash
agent-browser open <url>        # Navigate to URL
agent-browser close             # Close browser
```

### Snapshot & screenshots

```bash
agent-browser snapshot              # Accessibility tree with @refs
agent-browser screenshot [path]     # Screenshot (--full for full page, --annotate for labels)
agent-browser pdf <path>            # Save as PDF
```

### Interactions (use @refs from snapshot)

```bash
agent-browser click @e1             # Click
agent-browser dblclick @e1          # Double-click
agent-browser fill @e2 "text"       # Clear and type
agent-browser type @e2 "text"       # Type without clearing
agent-browser press Enter           # Press key
agent-browser press Control+a       # Key combination
agent-browser hover @e1             # Hover
agent-browser check @e1             # Check checkbox
agent-browser uncheck @e1           # Uncheck checkbox
agent-browser select @e1 "value"    # Select dropdown
agent-browser scroll down 500       # Scroll page
agent-browser scrollintoview @e1    # Scroll element into view
agent-browser drag @e1 @e2          # Drag and drop
agent-browser upload @e1 file.png   # Upload file
```

### Get information

```bash
agent-browser get text @e1          # Get element text
agent-browser get value @e1         # Get input value
agent-browser get html @e1          # Get innerHTML
agent-browser get attr @e1 href     # Get attribute
agent-browser get title             # Get page title
agent-browser get url               # Get current URL
agent-browser get count @e1         # Count matching elements
```

### State checks

```bash
agent-browser is visible @e1        # Check visibility
agent-browser is enabled @e1        # Check if enabled
agent-browser is checked @e1        # Check if checked
```

### Wait

```bash
agent-browser wait @e1              # Wait for element
agent-browser wait 2000             # Wait milliseconds
agent-browser wait --text "Success" # Wait for text
agent-browser wait --url "**/path"  # Wait for URL pattern
agent-browser wait --load networkidle
```

### Semantic locators (alternative to @refs)

```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find testid "login-btn" click
```

### Tabs

```bash
agent-browser tab                   # List tabs
agent-browser tab new [url]         # New tab
agent-browser tab <n>               # Switch to tab n
agent-browser tab close [n]         # Close tab
```

### Diff & comparison

```bash
agent-browser diff snapshot                          # Compare current vs last
agent-browser diff snapshot --baseline before.txt    # Compare vs saved file
agent-browser diff screenshot --baseline before.png  # Visual pixel diff
agent-browser diff url <url1> <url2>                 # Compare two URLs
```

### Evaluate JS

```bash
agent-browser eval "document.title"
```

### Network

```bash
agent-browser network requests              # View requests
agent-browser network requests --filter api # Filter
agent-browser network route <url> --abort   # Block requests
```

### Browser settings

```bash
agent-browser set viewport 1280 720
agent-browser set device "iPhone 15"
agent-browser set media dark
agent-browser set offline on
```

### Debugging

```bash
agent-browser console           # View console messages
agent-browser errors            # View uncaught errors
```

## Example: Form submission

```bash
agent-browser open https://example.com/form
agent-browser snapshot
# Output: textbox "Email" [ref=e1], textbox "Password" [ref=e2], button "Submit" [ref=e3]

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot  # Check result
```
