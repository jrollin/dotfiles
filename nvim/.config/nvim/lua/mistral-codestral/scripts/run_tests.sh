#!/bin/bash

# Mistral Autocomplete Visual Test Script
# This script sets up an interactive test environment

clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Mistral Codestral Autocomplete - Interactive Test       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Create test files
echo "📝 Creating test files..."

# JavaScript test file
cat > /tmp/mistral_visual_test.js << 'EOF'
// INSTRUCTIONS:
// 1. Go to line 8 (below "return") in insert mode
// 2. Wait 1 second after typing
// 3. You should see completion menu with 󰭶 icon for Mistral
// 4. Try pressing <leader>mc to force completion

// TEST 1: Simple function
function calculateSum(a, b) {
  return
}

// TEST 2: Array method (go to line 16, after the dot)
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.

// TEST 3: Async function (go to line 21, after await)
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  const data = await
}

// TEST 4: Object method (go to line 28)
const calculator = {
  add(a, b) {
    return
  },
  multiply(a, b) {
    return
  }
};

// HOW TO TEST:
// - Position cursor at empty spots above
// - In INSERT mode, type a few characters OR just wait
// - Watch for completion menu with 󰭶 icon
// - Press <Tab> to accept or <Esc> to cancel
EOF

# Python test file
cat > /tmp/mistral_visual_test.py << 'EOF'
# INSTRUCTIONS:
# Same as JavaScript test
# Look for completion menu with Mistral suggestions

# TEST 1: Simple function
def calculate_sum(a, b):
    return

# TEST 2: List comprehension
numbers = [1, 2, 3, 4, 5]
squared =

# TEST 3: Class method
class Calculator:
    def __init__(self):


    def add(self, a, b):
        return

# TEST 4: Exception handling
def divide(a, b):
    try:
        result =
    except ZeroDivisionError:

EOF

echo "✓ Test files created"
echo ""
echo "📋 Test Instructions:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Choose your test:"
echo "  1) JavaScript test  (recommended for first test)"
echo "  2) Python test"
echo "  3) Run automated verification first"
echo "  4) Check configuration and auth"
echo "  5) Exit"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
  1)
    echo ""
    echo "🚀 Opening JavaScript test file..."
    echo ""
    echo "WHAT TO DO:"
    echo "  1. Press 'i' to enter insert mode"
    echo "  2. Go to line 8, after 'return '"
    echo "  3. Type a few chars OR just wait 1 second"
    echo "  4. Look for completion menu with 󰭶 icon"
    echo "  5. Try manual completion: <leader>mc"
    echo ""
    echo "Press ENTER to continue..."
    read
    nvim /tmp/mistral_visual_test.js
    ;;

  2)
    echo ""
    echo "🐍 Opening Python test file..."
    echo ""
    echo "WHAT TO DO:"
    echo "  1. Press 'i' to enter insert mode"
    echo "  2. Go to line 8, after 'return '"
    echo "  3. Wait for completion menu"
    echo "  4. Look for 󰭶 icon (Mistral AI)"
    echo ""
    echo "Press ENTER to continue..."
    read
    nvim /tmp/mistral_visual_test.py
    ;;

  3)
    echo ""
    echo "🔍 Running automated verification..."
    echo ""

    # Check if nvim config loads
    echo "1. Testing Neovim config load..."
    if nvim --headless -u ~/.config/nvim/init.lua -c "lua print('OK')" -c "qa" 2>&1 | grep -q "OK"; then
      echo "   ✓ Config loads"
    else
      echo "   ✗ Config failed to load"
    fi

    # Check API key
    echo "2. Testing API key..."
    if nvim --headless -u ~/.config/nvim/init.lua \
           -c "lua local auth = require('mistral-codestral.auth'); local key = auth.get_api_key(); print(key and 'OK' or 'FAIL')" \
           -c "qa" 2>&1 | grep -q "OK"; then
      echo "   ✓ API key found"
    else
      echo "   ✗ API key not found"
    fi

    # Check blink.cmp
    echo "3. Testing blink.cmp integration..."
    if nvim --headless -u ~/.config/nvim/init.lua \
           -c "lua local ok = pcall(require, 'mistral-codestral.blink'); print(ok and 'OK' or 'FAIL')" \
           -c "qa" 2>&1 | grep -q "OK"; then
      echo "   ✓ Blink.cmp integration working"
    else
      echo "   ✗ Blink.cmp integration failed"
    fi

    # Test FIM API
    echo "4. Testing FIM API (this may take a few seconds)..."
    nvim --headless -u ~/.config/nvim/init.lua -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1 | grep -q "✓"
    if [ $? -eq 0 ]; then
      echo "   ✓ FIM API responding"
    else
      echo "   ✗ FIM API not responding"
    fi

    echo ""
    echo "✓ Verification complete. Press ENTER to return to menu..."
    read
    exec "$0"  # Restart menu
    ;;

  4)
    echo ""
    echo "⚙️  Configuration Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    nvim --headless -u ~/.config/nvim/init.lua -c 'lua
      local mistral = require("mistral-codestral")
      local auth = require("mistral-codestral.auth")
      local config = mistral.config()

      print("Configuration:")
      print("  Model: " .. config.model)
      print("  Max tokens: " .. config.max_tokens)
      print("  Engine: " .. config.completion_engine)
      print("  Debug: " .. tostring(config.debug))
      print("")
      print("Authentication:")
      local key = auth.get_api_key()
      if key then
        print("  Status: ✓ Valid")
        print("  Method: " .. auth.get_current_method())
        print("  Length: " .. #key .. " chars")
      else
        print("  Status: ✗ No API key")
      end
      print("")
      print("Blink.cmp:")
      local blink_ok = pcall(require, "blink.cmp")
      print("  Installed: " .. (blink_ok and "✓ Yes" or "✗ No"))

      local sources = require("blink.cmp").config.sources.providers
      if sources.mistral_codestral then
        print("  Mistral source: ✓ Registered")
        print("  Timeout: " .. sources.mistral_codestral.timeout_ms .. "ms")
        print("  Max items: " .. sources.mistral_codestral.max_items)
        print("  Score offset: " .. sources.mistral_codestral.score_offset)
      else
        print("  Mistral source: ✗ Not registered")
      end
    ' -c 'qa' 2>&1

    echo ""
    echo "Press ENTER to return to menu..."
    read
    exec "$0"  # Restart menu
    ;;

  5)
    echo "Goodbye!"
    exit 0
    ;;

  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "Test complete! Re-run this script to test again:"
echo "  bash /tmp/run_visual_test.sh"
