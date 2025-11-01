-- Test script for Mistral Codestral plugin
local test_results = {
  passed = 0,
  failed = 0,
  errors = {}
}

local function log_test(name, passed, message)
  if passed then
    test_results.passed = test_results.passed + 1
    print(string.format("✓ %s", name))
  else
    test_results.failed = test_results.failed + 1
    table.insert(test_results.errors, {name = name, message = message})
    print(string.format("✗ %s: %s", name, message or "unknown error"))
  end
end

local function run_tests()
  print("\n=== Mistral Codestral Plugin Tests ===\n")

  -- Test 1: Check if plugin is loaded
  local ok, mistral = pcall(require, "mistral-codestral")
  log_test("Plugin loads successfully", ok, not ok and "Failed to load plugin" or nil)

  if not ok then
    print("\n❌ Plugin failed to load. Cannot continue tests.")
    return test_results
  end

  -- Test 2: Check configuration
  local config = mistral.config()
  log_test("Configuration available", config ~= nil, "Config is nil")

  if config then
    log_test("API model configured", config.model ~= nil, "Model not set")
    log_test("Completion engine set", config.completion_engine ~= nil, "Engine not set")
    log_test("Max tokens configured", config.max_tokens ~= nil and config.max_tokens > 0, "Invalid max_tokens")
  end

  -- Test 3: Check authentication
  local auth_ok, auth = pcall(require, "mistral-codestral.auth")
  log_test("Auth module loads", auth_ok, not auth_ok and "Auth module failed" or nil)

  if auth_ok then
    local api_key = auth.get_api_key()
    log_test("API key available", api_key ~= nil and api_key ~= "", "No API key found")

    if api_key then
      local method = auth.get_current_method()
      log_test("API key method detected", method ~= "none", "Method is 'none'")
      print(string.format("  → Using method: %s", method))

      -- Test API key validation
      print("\n  Testing API key validity (this may take a few seconds)...")
      auth.validate_api_key(api_key, function(valid, error)
        log_test("API key is valid", valid, error)
      end)
      vim.wait(6000) -- Wait for async validation
    end
  end

  -- Test 4: Check blink.cmp integration
  local blink_ok, blink = pcall(require, "mistral-codestral.blink")
  log_test("Blink.cmp source loads", blink_ok, not blink_ok and "Blink source failed" or nil)

  if blink_ok then
    log_test("BlinkSource class available", blink.BlinkSource ~= nil, "BlinkSource is nil")
    log_test("get_completions method exists", blink.get_completions ~= nil, "Method missing")
  end

  -- Test 5: Check blink.cmp is available
  local blink_cmp_ok = pcall(require, "blink.cmp")
  log_test("Blink.cmp installed", blink_cmp_ok, "Blink.cmp not found")

  -- Test 6: Test buffer exclusion logic
  if ok then
    -- Create a test buffer
    local test_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(test_buf, 'filetype', 'lua')

    local excluded = mistral.is_buffer_excluded(test_buf)
    log_test("Normal buffer not excluded", not excluded, "Lua buffer was excluded")

    -- Test excluded filetype
    vim.api.nvim_buf_set_option(test_buf, 'filetype', 'help')
    excluded = mistral.is_buffer_excluded(test_buf)
    log_test("Help buffer is excluded", excluded, "Help buffer not excluded")

    vim.api.nvim_buf_delete(test_buf, {force = true})
  end

  -- Test 7: Test FIM context extraction
  if ok then
    -- Create a test buffer with content
    local test_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, {
      "function test() {",
      "  console.log('test');",
      "  ",
      "}"
    })
    vim.api.nvim_buf_set_option(test_buf, 'filetype', 'javascript')
    vim.api.nvim_set_current_buf(test_buf)
    vim.api.nvim_win_set_cursor(0, {3, 2}) -- Position at line 3, col 2

    local context = mistral.get_fim_context_enhanced()
    log_test("FIM context extraction", context ~= nil, "Context is nil")

    if context then
      log_test("Context has prefix", context.prefix ~= nil, "No prefix")
      log_test("Context has suffix", context.suffix ~= nil, "No suffix")
      log_test("Context has filetype", context.filetype ~= nil, "No filetype")
      print(string.format("  → Filetype: %s", context.filetype or "none"))
    end

    vim.api.nvim_buf_delete(test_buf, {force = true})
  end

  -- Test 8: Test completion request (actual API call)
  if ok and config and config.enabled then
    print("\n  Testing actual completion request (this may take a few seconds)...")
    local test_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, {
      "// Calculate the sum of two numbers",
      "function sum(a, b) {",
      "  "
    })
    vim.api.nvim_buf_set_option(test_buf, 'filetype', 'javascript')
    vim.api.nvim_set_current_buf(test_buf)
    vim.api.nvim_win_set_cursor(0, {3, 2})

    local completion_received = false
    mistral.request_completion(function(completion)
      completion_received = true
      log_test("Completion request successful", completion ~= nil, "No completion returned")

      if completion then
        print(string.format("  → Received completion (%d chars): %s",
          #completion,
          completion:gsub("\n", " "):sub(1, 50) .. "..."))
      end
    end)

    vim.wait(12000, function() return completion_received end) -- Wait up to 12 seconds

    if not completion_received then
      log_test("Completion request timeout", false, "Request timed out after 12s")
    end

    vim.api.nvim_buf_delete(test_buf, {force = true})
  end

  -- Print summary
  print("\n=== Test Summary ===")
  print(string.format("Passed: %d", test_results.passed))
  print(string.format("Failed: %d", test_results.failed))

  if #test_results.errors > 0 then
    print("\nFailed tests:")
    for _, err in ipairs(test_results.errors) do
      print(string.format("  - %s: %s", err.name, err.message))
    end
  end

  print("\n" .. (test_results.failed == 0 and "✓ All tests passed!" or "✗ Some tests failed"))

  return test_results
end

-- Run tests
local results = run_tests()
os.exit(results.failed == 0 and 0 or 1)
