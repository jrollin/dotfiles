-- lua/mistral-codestral/health.lua
-- Health check for the Mistral Codestral plugin

local M = {}

local function check_dependency(name, module_name, required)
  local status = required and "ERROR" or "WARNING"
  local ok, _ = pcall(require, module_name)

  if ok then
    vim.health.ok(name .. " is available")
  else
    if required then
      vim.health.error(name .. " is not available (required)")
    else
      vim.health.warn(name .. " is not available (optional)")
    end
  end

  return ok
end

local function check_binary(name, command)
  local handle = io.popen("which " .. command .. " 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  if result and result ~= "" then
    vim.health.ok(name .. " is available at: " .. result:gsub("\n", ""))
    return true
  else
    vim.health.error(name .. " is not available in PATH")
    return false
  end
end

-- Check API key (deprecated - now handled by auth module)
local function check_api_key()
  -- This function is kept for backward compatibility
  local auth = require("mistral-codestral.auth")
  return auth.get_api_key() ~= nil
end

local function check_mistral_api()
  local api_key = os.getenv("MISTRAL_API_KEY")
  if not api_key then
    local ok, mistral = pcall(require, "mistral-codestral")
    if ok then
      local config = mistral.config()
      api_key = config and config.api_key
    end
  end

  if not api_key then
    vim.health.error("Cannot test API connection without API key")
    return
  end

  -- Simple API test
  local test_cmd = {
    "curl",
    "-s",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. api_key,
    "-d",
    '{"model":"codestral-latest","prompt":"test","max_tokens":1}',
    "--max-time",
    "5",
    "https://codestral.mistral.ai/v1/fim/completions",
  }

  vim.fn.jobstart(test_cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and data[1] and data[1] ~= "" then
        local response = table.concat(data, "\n")
        local ok, parsed = pcall(vim.fn.json_decode, response)

        if ok and parsed then
          if parsed.error then
            vim.health.error("API connection failed: " .. (parsed.error.message or "Unknown error"))
          else
            vim.health.ok("API connection successful")
          end
        else
          vim.health.warn("API responded but response format unexpected")
        end
      end
    end,
    on_stderr = function(_, data)
      if data and data[1] and data[1] ~= "" then
        vim.health.error("API connection error: " .. table.concat(data, "\n"))
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.health.error("Failed to connect to Mistral API (exit code: " .. exit_code .. ")")
      end
    end,
  })
end

function M.check()
  vim.health.start("Mistral Codestral Plugin Health Check")

  -- Check Neovim version
  local nvim_version = vim.version()
  local version_string = string.format("%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch or 0)

  if vim.fn.has("nvim-0.9.0") == 1 then
    vim.health.ok("Neovim version: " .. version_string)
    if vim.fn.has("nvim-0.10.0") == 1 then
      vim.health.info("  Using vim.system for safe command execution ✓")
    else
      vim.health.info("  Using fallback command execution (upgrade to 0.10+ for vim.system)")
    end
  else
    vim.health.error("Neovim >= 0.9.0 required, current: " .. version_string, {
      "Upgrade to Neovim 0.9.0 or later",
      "Visit: https://github.com/neovim/neovim/releases"
    })
  end

  -- Check required dependencies
  vim.health.start("Dependencies")
  check_dependency("plenary.nvim", "plenary", false)
  check_dependency("nvim-cmp", "cmp", false)
  check_dependency("nvim-treesitter", "nvim-treesitter", false)

  -- Check system binaries
  vim.health.start("System Dependencies")
  check_binary("curl", "curl")

  -- Check HTTP client module
  vim.health.start("HTTP Client")
  local http_ok, http_client = pcall(require, "mistral-codestral.http_client")
  if http_ok then
    vim.health.ok("HTTP client module loaded")
    if type(http_client.post) == "function" and type(http_client.validate_api_key) == "function" then
      vim.health.ok("HTTP client functions available")
    else
      vim.health.error("HTTP client module is missing required functions")
    end
  else
    vim.health.error("HTTP client module failed to load", {
      "Check that http_client.lua exists in lua/mistral-codestral/",
      "Error: " .. tostring(http_client)
    })
  end

  -- Check authentication module
  vim.health.start("Authentication")
  local auth_ok, auth = pcall(require, "mistral-codestral.auth")
  if auth_ok then
    vim.health.ok("Auth module loaded")

    -- Check API key
    local api_key = auth.get_api_key()
    if api_key and api_key ~= "" then
      vim.health.ok("API key found (length: " .. #api_key .. " characters)")

      -- Show which method was used
      local method = auth.get_current_method()
      if method and method ~= "none" then
        vim.health.info("  Retrieved via: " .. method)
      end

      -- Test API connection if HTTP client is available
      if http_ok then
        check_mistral_api()
      end
    else
      vim.health.error("No API key configured", {
        "Set MISTRAL_API_KEY environment variable",
        "Or configure api_key in plugin setup",
        "Or run :MistralCodestralAuth set"
      })
    end
  else
    vim.health.error("Auth module failed to load", {
      "Check that auth.lua exists in lua/mistral-codestral/",
      "Error: " .. tostring(auth)
    })
  end

  -- Check plugin configuration
  vim.health.start("Plugin Configuration")
  local ok, mistral = pcall(require, "mistral-codestral")
  if ok then
    local config = mistral.config()
    if config then
      vim.health.ok("Plugin is configured")
      vim.health.info("Model: " .. (config.model or "not set"))
      vim.health.info("Max tokens: " .. (config.max_tokens or "not set"))
      vim.health.info("CMP source enabled: " .. tostring(config.enable_cmp_source))
      vim.health.info("Virtual text enabled: " .. tostring(config.virtual_text and config.virtual_text.enabled))
    else
      vim.health.warn("Plugin is loaded but not configured")
    end
  else
    vim.health.error("Plugin is not properly loaded")
  end

  -- Check LSP integration
  vim.health.start("LSP Integration")
  local lsp_clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #lsp_clients > 0 then
    vim.health.ok("LSP is active (" .. #lsp_clients .. " client(s))")
    for _, client in ipairs(lsp_clients) do
      vim.health.info("  - " .. client.name)
    end
  else
    vim.health.warn("No active LSP clients (LSP integration will be limited)")
  end

  -- Check nvim-cmp integration
  vim.health.start("Completion Engine Integration")

  -- Check nvim-cmp
  local nvim_cmp_ok, cmp = pcall(require, "cmp")
  if nvim_cmp_ok then
    local sources = cmp.get_config().sources or {}
    local has_mistral_source = false

    for _, source_group in ipairs(sources) do
      if type(source_group) == "table" then
        for _, source in ipairs(source_group) do
          if source.name == "mistral_codestral" then
            has_mistral_source = true
            break
          end
        end
      end
    end

    if has_mistral_source then
      vim.health.ok("mistral_codestral source is configured in nvim-cmp")
    else
      vim.health.warn("mistral_codestral source not found in nvim-cmp sources")
    end
  else
    vim.health.info("nvim-cmp is not available")
  end

  -- Check blink.cmp
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    local config = blink.get_config and blink.get_config()
    if config and config.sources and config.sources.providers then
      local has_mistral = config.sources.providers.mistral_codestral ~= nil

      if has_mistral then
        vim.health.ok("mistral_codestral provider is configured in blink.cmp")
      else
        vim.health.warn("mistral_codestral provider not found in blink.cmp")
      end

      -- Check if it's in default sources
      local default_sources = config.sources.default or {}
      local in_default = false
      for _, source_name in ipairs(default_sources) do
        if source_name == "mistral_codestral" then
          in_default = true
          break
        end
      end

      if in_default then
        vim.health.ok("mistral_codestral is in blink.cmp default sources")
      else
        vim.health.info("mistral_codestral not in default sources (this is okay if configured per-filetype)")
      end
    else
      vim.health.warn("Could not access blink.cmp configuration")
    end
  else
    vim.health.info("blink.cmp is not available")
  end

  -- Summary
  if not nvim_cmp_ok and not blink_ok then
    vim.health.error("No compatible completion engine found (nvim-cmp or blink.cmp required)")
  elseif nvim_cmp_ok and blink_ok then
    vim.health.ok("Both nvim-cmp and blink.cmp are available")
  end
end

return M
