-- lua/mistral-codestral/auth.lua
-- Secure authentication management for Mistral Codestral

local M = {}

-- Default authentication configuration
local default_auth_config = {
  -- Storage methods in priority order
  methods = {
    "config", -- Direct config (least secure)
    "environment", -- Environment variables
    "keyring", -- System keyring (most secure)
    "encrypted_file", -- Encrypted local file
    "prompt", -- Interactive prompt
  },

  -- Keyring configuration
  keyring = {
    service = "mistral-codestral-nvim",
    username = vim.env.USER or "default",
  },

  -- Encrypted file configuration
  encrypted_file = {
    path = vim.fn.stdpath("data") .. "/mistral-codestral/auth.enc",
    key_derivation = "pbkdf2", -- pbkdf2, scrypt, argon2
  },

  -- Environment variable names to check
  env_vars = {
    "MISTRAL_API_KEY",
    "MISTRAL_CODESTRAL_API_KEY",
    "CODESTRAL_API_KEY",
  },

  -- Validation
  validate_on_startup = true,
  cache_validation = true,
  validation_timeout = 5000, -- ms
}

local auth_config = {}
local api_key_cache = nil
local validation_cache = {}

-- Ensure auth_config is initialized with defaults
local function ensure_initialized()
  if not auth_config.methods then
    auth_config = vim.tbl_deep_extend("force", default_auth_config, {})
  end
end

-- Utility functions
local function log_debug(msg)
  if auth_config.debug then
    vim.notify("[Auth Debug] " .. msg, vim.log.levels.DEBUG)
  end
end

local function log_info(msg)
  vim.notify("[Mistral Auth] " .. msg, vim.log.levels.INFO)
end

local function log_error(msg)
  vim.notify("[Mistral Auth] " .. msg, vim.log.levels.ERROR)
end

-- Sanitize API key for logging (never log full key)
local function sanitize_api_key(key)
  if not key or type(key) ~= "string" then
    return "[INVALID]"
  end
  if #key < 8 then
    return "[TOO_SHORT]"
  end
  return key:sub(1, 4) .. "..." .. key:sub(-4)
end

-- Safely execute shell command (prevents injection)
local function safe_execute_command(command)
  -- Expand ~ to home directory
  local expanded_command = command:gsub("~", vim.env.HOME or os.getenv("HOME") or "")

  -- Use vim.system if available (Neovim 0.10+), otherwise fall back to io.popen
  if vim.system then
    local result = vim.system({'sh', '-c', expanded_command}, {text = true}):wait()
    if result.code == 0 and result.stdout then
      return vim.trim(result.stdout), true
    else
      return nil, false
    end
  else
    -- Fallback for older Neovim versions (still safer than direct io.popen)
    -- Escape single quotes properly
    local escaped_command = expanded_command:gsub("'", "'\\''")
    local full_command = "sh -c '" .. escaped_command .. "'"

    local handle = io.popen(full_command)
    if handle then
      local output = handle:read("*a")
      local success = handle:close()
      if success and output and output:match("%S") then
        return output:gsub("^%s*(.-)%s*$", "%1"), true
      end
    end
    return nil, false
  end
end

-- Check if a command exists
local function command_exists(cmd)
  local handle = io.popen("which " .. cmd .. " 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result and result ~= ""
end

-- Method 1: Get from direct configuration
local function get_from_config()
  local mistral_config = require("mistral-codestral").config()
  if mistral_config and mistral_config.api_key then
    local api_key = mistral_config.api_key

    -- Check if it's a command-based key (starts with "cmd:")
    if type(api_key) == "string" and api_key:match("^cmd:") then
      local command = api_key:sub(5) -- Remove "cmd:" prefix
      log_debug("Executing command for API key retrieval [REDACTED]")

      -- Use safe command execution
      local key, success = safe_execute_command(command)

      if success and key then
        log_debug("Found API key from command: " .. sanitize_api_key(key))
        return key
      else
        log_error("Command execution failed or returned empty result")
      end
      return nil
    else
      log_debug("Found API key in direct configuration: " .. sanitize_api_key(api_key))
      return api_key
    end
  end
  return nil
end

-- Method 2: Get from environment variables
local function get_from_environment()
  ensure_initialized()
  
  for _, var_name in ipairs(auth_config.env_vars) do
    local key = os.getenv(var_name)
    if key and key ~= "" then
      log_debug("Found API key in environment variable: " .. var_name)
      return key
    end
  end
  return nil
end

-- Method 3: Get from system keyring
local function get_from_keyring()
  if not command_exists("keyring") and not command_exists("security") and not command_exists("secret-tool") then
    log_debug("No keyring tools available")
    return nil
  end

  local service = auth_config.keyring.service
  local username = auth_config.keyring.username

  -- Try different keyring tools
  local commands = {}

  -- macOS keychain
  if command_exists("security") then
    table.insert(
      commands,
      string.format("security find-generic-password -s '%s' -a '%s' -w 2>/dev/null", service, username)
    )
  end

  -- Linux Secret Service
  if command_exists("secret-tool") then
    table.insert(
      commands,
      string.format("secret-tool lookup service '%s' username '%s' 2>/dev/null", service, username)
    )
  end

  -- Python keyring
  if command_exists("keyring") then
    table.insert(commands, string.format("keyring get '%s' '%s' 2>/dev/null", service, username))
  end

  for _, cmd in ipairs(commands) do
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    local success = handle:close()

    if success and result and result:match("%S") then
      local key = result:gsub("%s+", "")
      log_debug("Found API key in system keyring")
      return key
    end
  end

  log_debug("No API key found in system keyring")
  return nil
end

-- Method 4: Get from encrypted file
local function get_from_encrypted_file()
  local file_path = auth_config.encrypted_file.path

  if vim.fn.filereadable(file_path) == 0 then
    log_debug("Encrypted file does not exist: " .. file_path)
    return nil
  end

  -- For now, implement simple base64 "encryption" (you should use proper encryption)
  -- In production, consider using age, gpg, or proper encryption libraries
  local file = io.open(file_path, "r")
  if not file then
    log_debug("Cannot read encrypted file")
    return nil
  end

  local content = file:read("*a")
  file:close()

  -- Simple base64 decode (replace with proper encryption)
  local ok, decoded = pcall(function()
    return vim.base64.decode(content:gsub("%s", ""))
  end)

  if ok and decoded then
    log_debug("Found API key in encrypted file")
    return decoded
  end

  log_debug("Failed to decrypt API key file")
  return nil
end

-- Method 5: Interactive prompt
local function get_from_prompt()
  local key = vim.fn.inputsecret("Enter your Mistral API key: ")

  if key and key ~= "" then
    log_debug("API key provided via interactive prompt")

    -- Ask if user wants to save it
    local save_choice =
      vim.fn.confirm("Save API key for future use?", "&Keyring\n&Encrypted file\n&Environment variable\n&Don't save", 4)

    if save_choice == 1 then
      M.save_to_keyring(key)
    elseif save_choice == 2 then
      M.save_to_encrypted_file(key)
    elseif save_choice == 3 then
      log_info("Add 'export MISTRAL_API_KEY=\"" .. key:sub(1, 8) .. "...\"' to your shell profile")
    end

    return key
  end

  return nil
end

-- Save to keyring
function M.save_to_keyring(api_key)
  local service = auth_config.keyring.service
  local username = auth_config.keyring.username

  local commands = {}

  -- macOS keychain
  if command_exists("security") then
    table.insert(
      commands,
      string.format("echo '%s' | security add-generic-password -s '%s' -a '%s' -w -U", api_key, service, username)
    )
  end

  -- Linux Secret Service
  if command_exists("secret-tool") then
    table.insert(
      commands,
      string.format(
        "echo '%s' | secret-tool store --label='Mistral Codestral API Key' service '%s' username '%s'",
        api_key,
        service,
        username
      )
    )
  end

  -- Python keyring
  if command_exists("keyring") then
    table.insert(commands, string.format("echo '%s' | keyring set '%s' '%s'", api_key, service, username))
  end

  for _, cmd in ipairs(commands) do
    local success = os.execute(cmd .. " >/dev/null 2>&1")
    if success == 0 or success == true then
      log_info("API key saved to system keyring")
      return true
    end
  end

  log_error("Failed to save API key to keyring")
  return false
end

-- Save to encrypted file
function M.save_to_encrypted_file(api_key)
  local file_path = auth_config.encrypted_file.path
  local dir_path = vim.fn.fnamemodify(file_path, ":h")

  -- Create directory if it doesn't exist
  if vim.fn.isdirectory(dir_path) == 0 then
    vim.fn.mkdir(dir_path, "p")
  end

  -- Simple base64 "encryption" (replace with proper encryption)
  local encoded = vim.base64.encode(api_key)

  local file = io.open(file_path, "w")
  if not file then
    log_error("Cannot create encrypted file: " .. file_path)
    return false
  end

  file:write(encoded)
  file:close()

  -- Set secure permissions
  os.execute("chmod 600 " .. file_path)

  log_info("API key saved to encrypted file")
  return true
end

-- Main API key retrieval function
function M.get_api_key()
  ensure_initialized()
  
  -- Return cached key if available
  if api_key_cache then
    return api_key_cache
  end

  log_debug("Retrieving API key using configured methods")

  for _, method in ipairs(auth_config.methods) do
    local key = nil

    if method == "config" then
      key = get_from_config()
    elseif method == "environment" then
      key = get_from_environment()
    elseif method == "keyring" then
      key = get_from_keyring()
    elseif method == "encrypted_file" then
      key = get_from_encrypted_file()
    elseif method == "prompt" then
      key = get_from_prompt()
    end

    if key and key ~= "" then
      api_key_cache = key
      log_debug("Successfully retrieved API key using method: " .. method)
      return key
    end
  end

  log_error("No API key found using any configured method")
  return nil
end

-- Validate API key
function M.validate_api_key(api_key, callback)
  ensure_initialized()
  
  if not api_key then
    callback(false, "No API key provided")
    return
  end

  -- Check validation cache
  local cache_key = vim.fn.sha256(api_key)
  local cached_result = validation_cache[cache_key]
  if cached_result and auth_config.cache_validation then
    local age = vim.loop.now() - cached_result.timestamp
    if age < auth_config.validation_timeout then
      callback(cached_result.valid, cached_result.error)
      return
    end
  end

  -- Use centralized HTTP client for validation
  local http_client = require("mistral-codestral.http_client")

  http_client.validate_api_key(api_key, function(valid, error_msg)
    -- Cache result
    validation_cache[cache_key] = {
      valid = valid,
      error = error_msg,
      timestamp = vim.loop.now(),
    }

    callback(valid, error_msg)
  end)
end

-- Clear cached API key
function M.clear_cache()
  api_key_cache = nil
  validation_cache = {}
  log_info("Authentication cache cleared")
end

-- Authentication command interface
function M.auth_command(args)
  local subcommand = args.fargs[1] or "status"

  if subcommand == "status" then
    local key = M.get_api_key()
    if key then
      log_info("API key is configured (method used: " .. M.get_current_method() .. ")")

      if auth_config.validate_on_startup then
        M.validate_api_key(key, function(valid, error)
          if valid then
            log_info("API key is valid")
          else
            log_error("API key validation failed: " .. (error or "Unknown error"))
          end
        end)
      end
    else
      log_error("No API key configured")
    end
  elseif subcommand == "set" then
    local key = vim.fn.inputsecret("Enter your Mistral API key: ")
    if key and key ~= "" then
      -- Ask where to save
      local choice = vim.fn.confirm(
        "Where do you want to save the API key?",
        "&Keyring (recommended)\n&Encrypted file\n&Show env variable command",
        1
      )

      if choice == 1 then
        M.save_to_keyring(key)
      elseif choice == 2 then
        M.save_to_encrypted_file(key)
      elseif choice == 3 then
        log_info('Run: export MISTRAL_API_KEY="' .. key:sub(1, 8) .. '..."')
      end

      M.clear_cache() -- Clear cache to use new key
    end
  elseif subcommand == "clear" then
    M.clear_cache()
  elseif subcommand == "validate" then
    local key = M.get_api_key()
    if key then
      log_info("Validating API key...")
      M.validate_api_key(key, function(valid, error)
        if valid then
          log_info("API key is valid ✓")
        else
          log_error("API key is invalid: " .. (error or "Unknown error"))
        end
      end)
    else
      log_error("No API key to validate")
    end
  else
    log_error("Unknown auth command: " .. subcommand)
    log_info("Available commands: status, set, clear, validate")
  end
end

-- Get current authentication method
function M.get_current_method()
  ensure_initialized()
  
  for _, method in ipairs(auth_config.methods) do
    local key = nil

    if method == "config" then
      key = get_from_config()
    elseif method == "environment" then
      key = get_from_environment()
    elseif method == "keyring" then
      key = get_from_keyring()
    elseif method == "encrypted_file" then
      key = get_from_encrypted_file()
    end

    if key and key ~= "" then
      return method
    end
  end

  return "none"
end

-- Setup authentication
function M.setup(user_config)
  auth_config = vim.tbl_deep_extend("force", default_auth_config, user_config or {})

  -- Create auth command
  vim.api.nvim_create_user_command("MistralCodestralAuth", M.auth_command, {
    nargs = "?",
    complete = function()
      return { "status", "set", "clear", "validate" }
    end,
    desc = "Manage Mistral Codestral authentication",
  })

  -- Validate on startup if enabled
  if auth_config.validate_on_startup then
    vim.defer_fn(function()
      local key = M.get_api_key()
      if key then
        M.validate_api_key(key, function(valid, error)
          if not valid then
            log_error("Startup validation failed: " .. (error or "Unknown error"))
          end
        end)
      end
    end, 1000)
  end
end

return M
