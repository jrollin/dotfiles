// ===================================================================
// MISTRAL AUTOCOMPLETE STEP-BY-STEP TEST
// ===================================================================
//
// IMPORTANT: Read the instructions below before testing!
//
// This file will help you test Mistral completions properly.
// The key is understanding when completions trigger.
//
// TRIGGER REQUIREMENTS:
// 1. You must type at least 3 characters (min_keyword_length = 3)
// 2. Wait ~800ms after typing (idle_delay)
// 3. Be in INSERT mode
// 4. Buffer must not be excluded (this .js file is OK)
//
// ===================================================================

// TEST 1: Simple completion (SHOULD WORK)
// Steps:
// 1. Position cursor after "return " below
// 2. Press 'A' to go into INSERT mode at end of line
// 3. Type: "a +" (that's 3 characters including space)
// 4. Wait 1 second
// 5. You should see completion menu with suggestion "a + b"
//
function sum(a, b) {
  return
}

// -------------------------------------------------------------------

// TEST 2: Why "return " alone doesn't trigger
// The word "return" is only 6 chars, but when you're AFTER the space,
// the "word before cursor" is empty!
// You need to START TYPING something after return.
//
// Try this:
// 1. Position after "return " below
// 2. Press 'A' to enter INSERT mode
// 3. Type: "a" then wait - only 1 char, won't trigger
// 4. Type: "+ " (now it's "a + ", 3 chars total)
// 5. Wait 1 second - completion should appear!
//
function multiply(a, b) {
  return
}

// -------------------------------------------------------------------

// TEST 3: Array method (SHOULD WORK)
// This works because "map" is 3+ characters
//
// Steps:
// 1. Position cursor after the dot below
// 2. Press 'A' to enter INSERT mode
// 3. Type: "map" (3 characters)
// 4. Wait 1 second
// 5. Completion appears with array method suggestion!
//
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.

// -------------------------------------------------------------------

// TEST 4: Object property (SHOULD WORK)
//
// Steps:
// 1. Position cursor in the blank line inside greet()
// 2. Press 'o' to create new line and enter INSERT mode
// 3. Type: "ret" (3 characters)
// 4. Wait 1 second
// 5. Should see "return" completion
//
const user = {
  name: "John",
  age: 30,
  greet() {

  }
}

// -------------------------------------------------------------------

// TEST 5: Manual trigger (ALWAYS WORKS)
// If automatic completion doesn't work, try manual trigger
//
// Steps:
// 1. Position cursor after "return " below
// 2. Stay in NORMAL mode
// 3. Press: <leader>mc (usually ,mc or \mc)
// 4. Mistral will force a completion request
// 5. It should insert a suggestion directly
//
function divide(a, b) {
  return
}

// -------------------------------------------------------------------

// DEBUGGING: If completions still don't appear
//
// Run this command in Neovim:
//   :lua require('mistral-codestral.scripts.debug_completion').diagnose()
//
// Or create the command and run:
//   :DiagnoseMistral
//
// This will check:
// - Plugin loaded?
// - API key valid?
// - Blink.cmp configured?
// - Buffer excluded?
// - Minimum characters?
// - API responding?
//
// ===================================================================

// COMMON ISSUES:
//
// Issue 1: "I don't see ANY completions"
// - Check: :lua print(require('mistral-codestral').is_buffer_excluded())
// - Should return: false
//
// Issue 2: "I see LSP completions but not Mistral"
// - This is CORRECT! Mistral has lower priority than LSP
// - Look for the 󰭶 robot icon in the completion menu
// - Mistral appears BELOW LSP suggestions
//
// Issue 3: "Completions are too slow"
// - Check blink.cmp timeout: 2000ms (2 seconds)
// - Check idle delay: 800ms before trigger
// - Total wait time: up to 3 seconds
//
// Issue 4: "I only see completions sometimes"
// - Min 3 characters required
// - Wait for idle delay (800ms)
// - Some contexts may not have good completions
//
// ===================================================================

// WHAT SHOULD HAPPEN:
//
// When you type 3+ characters and wait ~1 second:
//
// ┌──────────────────────────────────┐
// │ return a + [cursor]              │
// │                                  │
// │ ┌── Completion Menu ───────────┐ │
// │ │ 󰊕 a              LSP        │ │  ← LSP first
// │ │ 󰊕 b              LSP        │ │
// │ │ 󰭶 a + b          Mistral    │ │  ← Mistral here!
// │ │ 󰦨 return         Buffer     │ │
// │ └──────────────────────────────┘ │
// └──────────────────────────────────┘
//
// The 󰭶 robot icon = Mistral AI
//
// ===================================================================
//
// QUICK COMMANDS:
//
// :MistralCodestralAuth status     - Check API key
// :MistralCodestralToggle          - Enable/disable plugin
// :MistralCodestralComplete        - Force completion
// :lua print(vim.inspect(require('blink.cmp').config.sources.providers.mistral_codestral))
//
// ===================================================================
