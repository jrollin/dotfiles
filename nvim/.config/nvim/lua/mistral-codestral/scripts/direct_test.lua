-- Direct test to see what's actually happening
-- Run this with: nvim -c "luafile ~/.config/nvim/lua/mistral-codestral/scripts/direct_test.lua"

print("\n=== DIRECT MISTRAL TEST ===\n")

-- Step 1: Check if plugin loads
print("Step 1: Loading plugin...")
local ok, mistral = pcall(require, "mistral-codestral")
if not ok then
  print("❌ FAILED: Plugin not loaded")
  print("   Error: " .. tostring(mistral))
  return
end
print("✓ Plugin loaded\n")

-- Step 2: Check commands exist
print("Step 2: Checking commands...")
local commands = vim.api.nvim_get_commands({})
if commands.MistralCodestralComplete then
  print("✓ :MistralCodestralComplete exists")
else
  print("❌ :MistralCodestralComplete NOT FOUND")
end

if commands.MistralCodestralToggle then
  print("✓ :MistralCodestralToggle exists")
else
  print("❌ :MistralCodestralToggle NOT FOUND")
end

if commands.MistralCodestralAuth then
  print("✓ :MistralCodestralAuth exists")
else
  print("❌ :MistralCodestralAuth NOT FOUND")
end
print("")

-- Step 3: Check configuration
print("Step 3: Checking configuration...")
local config = mistral.config()
if not config then
  print("❌ No configuration found")
  return
end

print("✓ Configuration loaded")
print("  Model: " .. (config.model or "nil"))
print("  Enabled: " .. tostring(config.enabled))
print("  Max tokens: " .. (config.max_tokens or "nil"))
print("")

-- Step 4: Check API key
print("Step 4: Checking API key...")
local auth = require("mistral-codestral.auth")
local api_key = auth.get_api_key()
if not api_key or api_key == "" then
  print("❌ No API key found")
  print("   Run: :MistralCodestralAuth set")
  return
end
print("✓ API key found (length: " .. #api_key .. ")")
print("")

-- Step 5: Test API directly with simple request
print("Step 5: Testing API with direct curl request...")
print("   (This will take a few seconds)\n")

local test_prompt = "function sum(a, b) {\n  return "
local test_suffix = "\n}"

local data = {
  model = "codestral-latest",
  prompt = test_prompt,
  suffix = test_suffix,
  max_tokens = 32,
  temperature = 0.0,
}

local json_data = vim.fn.json_encode(data)
local temp_file = vim.fn.tempname()
vim.fn.writefile({json_data}, temp_file)

local cmd = string.format(
  "curl -s -w '\\nHTTP_CODE:%%{http_code}' -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer %s' -d @%s --max-time 10 https://codestral.mistral.ai/v1/fim/completions",
  api_key,
  temp_file
)

local handle = io.popen(cmd)
local result = handle:read("*a")
handle:close()
vim.fn.delete(temp_file)

-- Parse result
local http_code = result:match("HTTP_CODE:(%d+)")
local response_body = result:gsub("HTTP_CODE:%d+", "")

print("   HTTP Code: " .. (http_code or "unknown"))

if http_code ~= "200" then
  print("❌ API request failed")
  print("   Response: " .. response_body:sub(1, 200))

  if http_code == "401" then
    print("\n   ERROR: Invalid API key")
    print("   Check your API key in ~/.mistral_codestral_key")
  elseif http_code == "429" then
    print("\n   ERROR: Rate limit exceeded")
  end
  return
end

local parse_ok, response = pcall(vim.fn.json_decode, response_body)
if not parse_ok then
  print("❌ Failed to parse response")
  print("   Response: " .. response_body:sub(1, 200))
  return
end

if response.choices and response.choices[1] then
  local completion = response.choices[1].text or (response.choices[1].message and response.choices[1].message.content) or ""
  if completion ~= "" then
    print("✓ API responding correctly")
    print("   Completion: '" .. completion:gsub("\n", "\\n") .. "'")
  else
    print("⚠️  API responded but with empty completion")
    print("   This might be normal for some contexts")
  end
elseif response.error then
  print("❌ API returned error:")
  print("   " .. vim.inspect(response.error))
  return
else
  print("⚠️  Unexpected response format")
  print("   " .. vim.inspect(response):sub(1, 200))
end
print("")

-- Step 6: Test plugin's request_completion function
print("Step 6: Testing plugin's request_completion function...")

-- Create a test buffer
local test_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, {
  "function sum(a, b) {",
  "  return ",
  "}"
})
vim.api.nvim_buf_set_option(test_buf, 'filetype', 'javascript')
vim.api.nvim_set_current_buf(test_buf)
vim.api.nvim_win_set_cursor(0, {2, 9}) -- After "return "

local completion_received = false
local completion_result = nil

print("   Requesting completion...")
mistral.request_completion(function(completion)
  completion_received = true
  completion_result = completion
end)

-- Wait for completion
local wait_time = 0
local max_wait = 10000 -- 10 seconds
while not completion_received and wait_time < max_wait do
  vim.wait(100)
  wait_time = wait_time + 100
end

if completion_received then
  if completion_result and completion_result ~= "" then
    print("✓ Plugin request_completion works!")
    print("   Result: '" .. completion_result:gsub("\n", "\\n"):sub(1, 50) .. "'")
  else
    print("⚠️  Completion received but empty")
    print("   The API might not have a good suggestion for this context")
  end
else
  print("❌ Timeout waiting for completion")
  print("   The request may have failed silently")
end
print("")

-- Step 7: Check blink.cmp integration
print("Step 7: Checking blink.cmp integration...")
local blink_ok, blink_cmp = pcall(require, "blink.cmp")
if not blink_ok then
  print("❌ blink.cmp not loaded")
  print("   Completions won't appear in menu")
  return
end
print("✓ blink.cmp loaded")

-- Check if source is registered
local source_ok, blink_source = pcall(require, "mistral-codestral.blink")
if not source_ok then
  print("❌ mistral-codestral.blink source not loaded")
  print("   Error: " .. tostring(blink_source))
  return
end
print("✓ Mistral blink.cmp source loaded")

-- Try to get config
local config_ok, blink_config = pcall(function()
  if blink_cmp.config then
    return blink_cmp.config
  end
  return nil
end)

if config_ok and blink_config then
  print("✓ blink.cmp config accessible")

  -- Check sources
  if blink_config.sources and blink_config.sources.default then
    local has_mistral = false
    for _, source in ipairs(blink_config.sources.default) do
      if source == "mistral_codestral" then
        has_mistral = true
        break
      end
    end

    if has_mistral then
      print("✓ mistral_codestral in sources.default")
    else
      print("❌ mistral_codestral NOT in sources.default")
      print("   Current sources: " .. vim.inspect(blink_config.sources.default))
    end
  end

  -- Check provider config
  if blink_config.sources and blink_config.sources.providers and blink_config.sources.providers.mistral_codestral then
    local provider = blink_config.sources.providers.mistral_codestral
    print("✓ mistral_codestral provider configured")
    print("  Enabled: " .. tostring(provider.enabled))
    print("  Min keyword length: " .. (provider.min_keyword_length or "default"))

    if not provider.enabled then
      print("\n❌ PROVIDER IS DISABLED!")
      print("   Set enabled = true in blink.cmp config")
    end
  else
    print("❌ mistral_codestral provider not configured")
  end
else
  print("⚠️  Cannot access blink.cmp config (may not be initialized yet)")
end
print("")

-- Step 8: Check keybindings
print("Step 8: Checking keybindings...")
print("   Leader key: " .. vim.g.mapleader or "\\")
print("   Expected: <leader>mc for manual completion")
print("   Try: :" .. (vim.g.mapleader or "\\") .. "mc")
print("")

-- Cleanup
vim.api.nvim_buf_delete(test_buf, {force = true})

print("=== SUMMARY ===")
print("1. Plugin: " .. (ok and "✓ Loaded" or "❌ Not loaded"))
print("2. Commands: " .. (commands.MistralCodestralComplete and "✓ Exist" or "❌ Missing"))
print("3. API Key: " .. (api_key and "✓ Found" or "❌ Missing"))
print("4. API Test: " .. (http_code == "200" and "✓ Works" or "❌ Failed"))
print("5. Plugin Function: " .. (completion_received and "✓ Works" or "❌ Failed"))
print("6. Blink.cmp: " .. (blink_ok and "✓ Loaded" or "❌ Not loaded"))
print("")

if not ok or not api_key or http_code ~= "200" or not completion_received then
  print("❌ ISSUES FOUND - Completions won't work")
  print("\nNext steps:")
  if not api_key then
    print("  1. Set API key: :MistralCodestralAuth set")
  end
  if http_code ~= "200" then
    print("  2. Fix API access (check key and network)")
  end
  if not completion_received then
    print("  3. Check Neovim messages: :messages")
  end
else
  print("✓ Everything looks good!")
  print("\nIf completions still don't appear:")
  print("  1. Make sure you type 3+ characters")
  print("  2. Wait 1-2 seconds after typing")
  print("  3. Look for 󰭶 icon in completion menu (below LSP items)")
  print("  4. Try manual trigger: <leader>mc")
  print("  5. Check :messages for errors")
end

print("\nPress any key to exit...")
vim.fn.getchar()
vim.cmd("qa!")
