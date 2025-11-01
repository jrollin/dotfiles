# Changelog

## [Unreleased] - 2025-10-31

### Fixed
- **CRITICAL FIX**: Response parsing bug in `init.lua` line 496
  - **Issue**: Plugin was looking for `response.choices[1].text` but Mistral API returns completions in `response.choices[1].message.content`
  - **Symptom**: No completions appeared (neither automatic nor manual trigger)
  - **Fix**: Updated response parsing to handle both formats:
    ```lua
    local completion = choice.text or (choice.message and choice.message.content)
    ```
  - **Impact**: Completions now work correctly for all users

### Added
- Comprehensive diagnostic scripts in `scripts/`:
  - `debug_completion.lua` - Full diagnostic check (run with `:DiagnoseMistral`)
  - `direct_test.lua` - Step-by-step verification test
  - `verify_fix.lua` - Verify the response parsing fix works
  - `diagnose.sh` - Quick command-line diagnostic
- Enhanced test fixtures:
  - `step-by-step-test.js` - Detailed testing instructions
- Documentation improvements:
  - `TROUBLESHOOTING.md` - Common issues and solutions
  - `ORGANIZATION.md` - File structure documentation
  - `CHANGELOG.md` - This file

### Changed
- Organized all test files and documentation into proper structure:
  - `docs/` - All documentation
  - `tests/` - All test files and fixtures
  - `scripts/` - Utility scripts
- Updated main README with testing section
- Improved error handling in diagnostic scripts

## Verification

To verify the fix works after updating:

```bash
# Method 1: Quick verification
nvim -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/scripts/verify_fix.lua"

# Method 2: Full diagnostic
nvim -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/scripts/direct_test.lua"

# Method 3: Manual test
nvim ~/.config/nvim/lua/mistral-codestral/tests/fixtures/step-by-step-test.js
# Then: Type "a + " after "return" and wait
```

## API Response Format

For reference, Mistral Codestral API returns:

```json
{
  "choices": [{
    "index": 0,
    "message": {
      "content": "a + b;"
    }
  }]
}
```

Some documentation suggested it returns:
```json
{
  "choices": [{
    "text": "a + b;"
  }]
}
```

The fix now handles **both formats** to ensure compatibility.

---

**Date**: 2025-10-31
**Affected Files**: `init.lua` line 496
**Severity**: Critical (completions didn't work at all)
**Status**: ✅ Fixed
