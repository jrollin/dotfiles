-- Debug script to check why completions aren't showing
-- Run this from within Neovim when you're not seeing completions

local M = {}

function M.diagnose()
  print("=== Mistral Completion Diagnostics ===\n")

  local issues = {}
  local checks_passed = 0
  local checks_failed = 0

  local function check(name, condition, fix)
    if condition then
      print("✓ " .. name)
      checks_passed = checks_passed + 1
      return true
    else
      print("✗ " .. name)
      if fix then
        print("  Fix: " .. fix)
      end
      table.insert(issues, {name = name, fix = fix})
      checks_failed = checks_failed + 1
      return false
    end
  end

  -- Check 1: Plugin loaded
  local ok, mistral = pcall(require, "mistral-codestral")
  check("Plugin loaded", ok, "Check :Lazy and ensure mistral-codestral is installed")

  if not ok then
    print("\n❌ Cannot continue - plugin not loaded")
    return
  end

  -- Check 2: Current buffer info
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype

  print("\n📝 Current Buffer Info:")
  print("  Buffer: " .. bufnr)
  print("  File: " .. (bufname ~= "" and bufname or "[No Name]"))
  print("  Filetype: " .. (filetype ~= "" and filetype or "[none]"))
  print("  Buftype: " .. (buftype ~= "" and buftype or "[normal]"))
  print("")

  -- Check 3: Buffer not excluded
  local excluded = mistral.is_buffer_excluded(bufnr)
  check("Buffer not excluded", not excluded,
    "Buffer is excluded. Check filetype and buffer patterns in config")

  -- Check 4: Plugin enabled
  local config = mistral.config()
  check("Plugin enabled globally", config.enabled,
    "Run :MistralCodestralToggle to enable")

  -- Check 5: API key present
  local auth = require("mistral-codestral.auth")
  local api_key = auth.get_api_key()
  check("API key configured", api_key ~= nil and api_key ~= "",
    "Run :MistralCodestralAuth set or check ~/.mistral_codestral_key")

  -- Check 6: Blink.cmp loaded
  local blink_ok, blink_cmp = pcall(require, "blink.cmp")
  check("Blink.cmp loaded", blink_ok,
    "Install blink.cmp: require('lazy').install('blink.cmp')")

  -- Store sources and min_chars for later use
  local sources = nil
  local min_chars = 3

  if blink_ok then
    -- Try to get config safely
    local config_ok, blink_config = pcall(function()
      -- Try different ways to access config
      if blink_cmp.config then
        return blink_cmp.config
      elseif type(blink_cmp.get_config) == "function" then
        return blink_cmp.get_config()
      else
        return nil
      end
    end)

    if config_ok and blink_config then
      sources = blink_config.sources

      -- Check 7: Mistral source registered
      local has_mistral = false
      if sources and sources.default then
        for _, source in ipairs(sources.default) do
          if source == "mistral_codestral" then
            has_mistral = true
            break
          end
        end
      end
      check("Mistral source in blink.cmp sources", has_mistral,
        "Add 'mistral_codestral' to sources.default in blink.cmp config")

      -- Check 8: Provider configured
      if sources and sources.providers and sources.providers.mistral_codestral then
        local provider = sources.providers.mistral_codestral
        print("\n⚙️  Blink.cmp Provider Settings:")
        print("  Enabled: " .. tostring(provider.enabled))
        print("  Async: " .. tostring(provider.async))
        print("  Timeout: " .. (provider.timeout_ms or "default") .. "ms")
        print("  Max items: " .. (provider.max_items or "default"))
        print("  Min keyword length: " .. (provider.min_keyword_length or "default"))
        print("  Score offset: " .. (provider.score_offset or "default"))
        print("")

        -- Store min_chars for later
        min_chars = provider.min_keyword_length or 3

        check("Provider enabled", provider.enabled,
          "Set enabled = true in blink.cmp mistral_codestral provider config")
      else
        check("Provider configured", false,
          "Add mistral_codestral provider config to blink.cmp")
      end
    else
      print("\n⚠️  Warning: Cannot access blink.cmp config")
      print("  Blink.cmp is loaded but config is not accessible yet")
      print("  This may be normal if blink.cmp hasn't fully initialized")
      print("  Try running diagnostics again after opening a file\n")

      -- Still try to check if source exists
      local source_ok, mistral_source = pcall(require, "mistral-codestral.blink")
      check("Mistral blink.cmp source exists", source_ok,
        "Check that mistral-codestral.blink module loads")
    end
  end

  -- Check 9: Cursor position and context
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  print("\n📍 Cursor Position:")
  print("  Line: " .. row .. ", Column: " .. col)

  -- Get current line
  local line = vim.api.nvim_get_current_line()
  print("  Current line: " .. line)
  print("  Line length: " .. #line)
  print("")

  -- Check 10: Enough characters typed
  local before_cursor = line:sub(1, col)
  local word_before = before_cursor:match("%S+$") or ""
  print("📝 Text Context:")
  print("  Before cursor: '" .. before_cursor .. "'")
  print("  Word before cursor: '" .. word_before .. "'")
  print("  Word length: " .. #word_before)
  print("")

  -- min_chars already set from blink.cmp config check above
  check("Enough characters typed (" .. min_chars .. "+ required)",
    #word_before >= min_chars or col > min_chars,
    "Type at least " .. min_chars .. " characters")

  -- Check 11: Test API directly
  print("\n🔍 Testing Mistral API directly...")
  print("   (This may take a few seconds)")

  local test_success = false
  local test_result = nil

  -- Simple API test
  local test_data = {
    model = "codestral-latest",
    prompt = "function sum(a, b) {\n  return ",
    suffix = "\n}",
    max_tokens = 16,
    temperature = 0.0,
  }

  local json_data = vim.fn.json_encode(test_data)
  local temp_file = vim.fn.tempname()
  vim.fn.writefile({json_data}, temp_file)

  if api_key then
    local cmd = string.format(
      "curl -s -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer %s' -d @%s --max-time 5 https://codestral.mistral.ai/v1/fim/completions",
      api_key,
      temp_file
    )

    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    vim.fn.delete(temp_file)

    local ok_parse, response = pcall(vim.fn.json_decode, result)
    if ok_parse and response then
      if response.choices and response.choices[1] then
        local completion = response.choices[1].text or (response.choices[1].message and response.choices[1].message.content)
        if completion and completion ~= "" then
          test_success = true
          test_result = completion
        end
      elseif response.error then
        test_result = "API Error: " .. (response.error.message or vim.inspect(response.error))
      end
    end
  end

  check("API responds to test request", test_success,
    test_result or "Check API key and network connection")

  if test_result and test_success then
    print("  Sample completion: '" .. test_result:gsub("\n", "\\n") .. "'")
    print("")
  end

  -- Summary
  print("\n" .. string.rep("=", 50))
  print("Summary:")
  print("  ✓ Checks passed: " .. checks_passed)
  print("  ✗ Checks failed: " .. checks_failed)

  if #issues > 0 then
    print("\n🔧 Actions to take:")
    for i, issue in ipairs(issues) do
      print("  " .. i .. ". " .. issue.name)
      if issue.fix then
        print("     → " .. issue.fix)
      end
    end
  else
    print("\n✅ All checks passed!")
    print("\nℹ️  If you still don't see completions:")
    print("  1. Make sure you're in INSERT mode")
    print("  2. Type at least " .. min_chars .. " characters")
    print("  3. Wait for completion delay (~800ms)")
    print("  4. Try manual trigger: <leader>mc")
    print("  5. Check Neovim notifications for errors")
  end

  print("\n📖 For more help, see:")
  print("  ~/.config/nvim/lua/mistral-codestral/docs/testing-guide.md")
end

-- Auto-run if called as a command
if vim.fn.exists(":DiagnoseMistral") == 0 then
  vim.api.nvim_create_user_command("DiagnoseMistral", function()
    M.diagnose()
  end, { desc = "Diagnose Mistral completion issues" })
end

return M
