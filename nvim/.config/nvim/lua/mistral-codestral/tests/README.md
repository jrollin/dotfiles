# Mistral Codestral Tests

Automated test suite for the Mistral Codestral Neovim plugin.

## Test Files

### [integration_test.lua](integration_test.lua)
**Complete integration test suite**

Comprehensive tests covering all plugin functionality:
- Plugin initialization
- Configuration loading
- API key authentication
- Buffer exclusion logic
- FIM context extraction
- LSP utils integration
- User commands

**Run with:**
```bash
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/integration_test.lua" 2>&1
```

**Expected output:**
```
✓ Plugin initialization
✓ Blink.cmp integration
✓ API key authentication
✓ Configuration settings
... (all tests passing)
✓ All integration tests passed!
```

### [api_test.lua](api_test.lua)
**Mistral FIM API tests**

Tests direct API calls to Mistral Codestral service:
- JavaScript completions (functions, arrays, objects)
- Python completions (functions, classes, lists)
- API response validation
- Error handling

**Run with:**
```bash
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1
```

**Expected output:**
```
Test: JavaScript: Simple return statement
✓ Result: a + b;

Test: JavaScript: Array map method
✓ Result: map((number) => number * 2);

Test: Python: Simple function return
✓ Result: a + b
...
✓ All API tests passed!
```

### [plugin_test.lua](plugin_test.lua)
**Plugin component tests**

Detailed tests of individual plugin components:
- Authentication methods
- Blink.cmp source registration
- Virtual text mode
- Exclusion patterns
- Configuration validation

**Run with:**
```bash
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/plugin_test.lua" 2>&1
```

## Test Fixtures

The `fixtures/` directory contains sample code files for manual testing:

### [fixtures/example.js](fixtures/example.js)
JavaScript test file with various scenarios:
- Function completions
- Array methods
- Async/await
- Object manipulation
- Error handling

### [fixtures/example.py](fixtures/example.py)
Python test file with test cases:
- Function definitions
- List comprehensions
- Class definitions
- Exception handling
- Decorators

**Use fixtures for:**
```bash
# Open and manually test
nvim ~/.config/nvim/lua/mistral-codestral/tests/fixtures/example.js

# Position cursor at blank lines
# Wait for completions to appear
# Verify Mistral suggestions with 󰭶 icon
```

## Running Tests

### Quick Test (Recommended)
Run the interactive test menu:
```bash
bash ~/.config/nvim/lua/mistral-codestral/scripts/run_tests.sh
```

This provides options to:
1. Test JavaScript interactively
2. Test Python interactively
3. Run automated verification
4. Check configuration

### Run All Tests
```bash
cd ~/.config/nvim/lua/mistral-codestral/tests

# Integration tests
nvim --headless -u ~/.config/nvim/init.lua -c "luafile integration_test.lua" 2>&1

# API tests
nvim --headless -u ~/.config/nvim/init.lua -c "luafile api_test.lua" 2>&1

# Plugin tests
nvim --headless -u ~/.config/nvim/init.lua -c "luafile plugin_test.lua" 2>&1
```

### Quick Verification
```bash
# Just check if API responds
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/tests/api_test.lua" 2>&1 | grep "✓"
```

## Test Standards

### Test Structure
Each test file follows this pattern:
```lua
-- Test description
local tests_passed = 0
local tests_failed = 0

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    tests_passed = tests_passed + 1
    print("✓ " .. name)
  else
    tests_failed = tests_failed + 1
    print("✗ " .. name .. ": " .. tostring(err))
  end
end

-- Run tests
test("Test name", function()
  assert(condition, "Error message")
end)

-- Summary
print("\n=== Test Summary ===")
print(string.format("Passed: %d", tests_passed))
print(string.format("Failed: %d", tests_failed))
```

### Test Categories

1. **Unit Tests** - Individual functions
2. **Integration Tests** - Component interaction
3. **API Tests** - External service calls
4. **Manual Tests** - Visual verification

### Success Criteria

Tests should:
- ✅ Run in headless mode
- ✅ Provide clear output
- ✅ Exit with proper code (0 = success)
- ✅ Complete within timeout
- ✅ Clean up resources

## Writing New Tests

### Basic Test Template

```lua
-- tests/my_test.lua
local mistral = require("mistral-codestral")

print("=== My Test ===\n")

local function test_feature()
  -- Test code here
  local result = mistral.some_function()
  assert(result ~= nil, "Function returned nil")
  print("✓ Test passed")
end

local ok, err = pcall(test_feature)
if not ok then
  print("✗ Test failed: " .. err)
  os.exit(1)
end

print("\n✓ All tests passed")
os.exit(0)
```

### Running Your Test

```bash
nvim --headless -u ~/.config/nvim/init.lua -c "luafile tests/my_test.lua" 2>&1
```

## Troubleshooting Tests

### Test Fails: "Plugin not loaded"
**Solution:** Check your init.lua loads the plugin
```vim
:lua print(require('mistral-codestral'))
```

### Test Fails: "API key not found"
**Solution:** Verify API key exists
```bash
cat ~/.mistral_codestral_key
```

### Test Timeout
**Solution:** Increase timeout in test file
```lua
vim.wait(15000)  -- Increase from default
```

### Tests Pass But Manual Testing Fails
**Solution:** Check buffer exclusions
```vim
:lua print(require('mistral-codestral').is_buffer_excluded())
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Mistral Plugin

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Neovim
        run: |
          sudo add-apt-repository ppa:neovim-ppa/stable
          sudo apt-get update
          sudo apt-get install -y neovim
      - name: Run tests
        env:
          MISTRAL_API_KEY: ${{ secrets.MISTRAL_API_KEY }}
        run: |
          nvim --headless -u init.lua \
            -c "luafile lua/mistral-codestral/tests/integration_test.lua"
```

## Test Coverage

Current coverage:
- ✅ Plugin initialization (100%)
- ✅ Authentication (100%)
- ✅ API integration (100%)
- ✅ Blink.cmp source (100%)
- ✅ Configuration (100%)
- ✅ Buffer exclusion (100%)
- ✅ Context extraction (100%)

## Contributing Tests

When adding tests:
1. **Follow existing patterns** - Use test() function wrapper
2. **Add clear descriptions** - Explain what's being tested
3. **Use assertions** - Make failures informative
4. **Clean up resources** - Delete test buffers/files
5. **Update this README** - Document new tests

## Related Documentation

- [../docs/testing-guide.md](../docs/testing-guide.md) - Manual testing guide
- [../docs/quick-start.md](../docs/quick-start.md) - Quick testing
- [../docs/test-report.md](../docs/test-report.md) - Expected results

## File Organization

```
tests/
├── README.md              # This file
├── integration_test.lua   # Full integration tests
├── api_test.lua          # API functionality tests
├── plugin_test.lua       # Component tests
└── fixtures/             # Test data files
    ├── example.js        # JavaScript test file
    └── example.py        # Python test file
```

---

**Last Updated:** 2025-10-31
**Test Framework:** Custom Lua
**Neovim Version:** 0.9.0+
**API:** Mistral Codestral FIM
