-- Verification script to test the fix
-- Run after restarting Neovim

print("\n" .. string.rep("=", 60))
print("  MISTRAL CODESTRAL - FIX VERIFICATION")
print(string.rep("=", 60) .. "\n")

local function test(name, fn)
  io.write(name .. "... ")
  io.flush()
  local ok, result = pcall(fn)
  if ok then
    print("✓")
    return true, result
  else
    print("✗")
    print("  Error: " .. tostring(result))
    return false, result
  end
end

-- Test 1: Plugin loads
local plugin_ok, mistral = test("1. Loading plugin", function()
  return require("mistral-codestral")
end)

if not plugin_ok then
  print("\n❌ Cannot continue - plugin not loaded")
  return
end

-- Test 2: API key
local key_ok, api_key = test("2. Getting API key", function()
  local auth = require("mistral-codestral.auth")
  local key = auth.get_api_key()
  assert(key and key ~= "", "No API key")
  return key
end)

if not key_ok then
  print("\n❌ Cannot continue - no API key")
  return
end

-- Test 3: Create test buffer
local buf_ok, test_buf = test("3. Creating test buffer", function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "function sum(a, b) {",
    "  return ",
    "}"
  })
  vim.api.nvim_buf_set_option(buf, 'filetype', 'javascript')
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_win_set_cursor(0, {2, 9})
  return buf
end)

if not buf_ok then
  print("\n❌ Cannot continue - buffer creation failed")
  return
end

-- Test 4: Request completion
print("\n4. Testing completion request (may take a few seconds)...")

local completion_received = false
local completion_result = nil
local completion_error = nil

mistral.request_completion(function(completion)
  completion_received = true
  completion_result = completion
end)

-- Wait for response
local max_wait = 10000 -- 10 seconds
local waited = 0
while not completion_received and waited < max_wait do
  vim.wait(100)
  waited = waited + 100

  -- Show progress
  if waited % 1000 == 0 then
    io.write(".")
    io.flush()
  end
end

print("")

if not completion_received then
  print("   ✗ Timeout waiting for completion")
  completion_error = "Request timed out after " .. (max_wait/1000) .. " seconds"
elseif not completion_result or completion_result == "" then
  print("   ✗ Received empty completion")
  completion_error = "Completion was nil or empty"
else
  print("   ✓ Completion received!")
  print("   Result: '" .. completion_result:gsub("\n", "\\n") .. "'")
end

-- Test 5: Test manual completion command
print("\n5. Testing manual completion command...")
local cmd_ok = test("   Command exists", function()
  local commands = vim.api.nvim_get_commands({})
  assert(commands.MistralCodestralComplete, "Command not found")
  return true
end)

-- Clean up
if test_buf and vim.api.nvim_buf_is_valid(test_buf) then
  vim.api.nvim_buf_delete(test_buf, {force = true})
end

-- Summary
print("\n" .. string.rep("=", 60))
print("  SUMMARY")
print(string.rep("=", 60))

local all_passed = plugin_ok and key_ok and buf_ok and completion_received and completion_result and cmd_ok

if all_passed then
  print("\n✅ ALL TESTS PASSED!")
  print("\nThe fix is working correctly! 🎉")
  print("\nNext steps:")
  print("  1. Open a JavaScript or Python file")
  print("  2. Type 3+ characters in insert mode")
  print("  3. Wait 1 second for completion menu")
  print("  4. Look for 󰭶 icon (Mistral AI)")
  print("\nOr use manual trigger:")
  print("  <leader>mc  (usually ,mc or \\mc)")
else
  print("\n❌ SOME TESTS FAILED")
  print("\nFailed checks:")
  if not plugin_ok then print("  - Plugin not loaded") end
  if not key_ok then print("  - API key missing") end
  if not buf_ok then print("  - Buffer creation failed") end
  if not completion_received or not completion_result then
    print("  - Completion request failed")
    if completion_error then
      print("    Error: " .. completion_error)
    end
  end
  if not cmd_ok then print("  - Commands not registered") end

  print("\nTroubleshooting:")
  print("  1. Make sure you restarted Neovim after the fix")
  print("  2. Check :messages for errors")
  print("  3. Run: :Lazy reload mistral-codestral.nvim")
  print("  4. Verify API key: :MistralCodestralAuth status")
end

print("\n" .. string.rep("=", 60) .. "\n")

-- Don't exit automatically, let user read results
print("Press any key to close...")
vim.fn.getchar()
vim.cmd("qa!")
