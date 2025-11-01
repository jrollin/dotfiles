-- lua/mistral-codestral/init.lua
local M = {}

-- Default configuration
local default_config = {
  api_key = nil, -- Set via environment variable MISTRAL_API_KEY or config
  model = "codestral-latest",
  max_tokens = 256,
  temperature = 0.1,
  stop_tokens = { "\n\n" },
  timeout = 10000, -- 10 seconds
  enabled = true, -- Global enable/disable
  debug = false, -- Enable debug logging

  -- Completion engine integration
  enable_cmp_source = true,
  cmp_max_items = 5,
  completion_engine = "blink.cmp", -- "auto", "nvim-cmp", "blink.cmp", "both"

  -- Virtual text configuration
  virtual_text = {
    enabled = false,
    manual = false,
    idle_delay = 200,
    min_chars = 1, -- Minimum characters required before showing suggestions
    priority = 65535,
    filetypes = {},
    default_filetype_enabled = true,
    key_bindings = {
      accept = "<Tab>",
      accept_word = "<C-Right>",
      accept_line = "<C-Down>",
      next = "<M-]>",
      prev = "<M-[>",
      clear = "<C-c>",
    },
  },

  -- Buffer and filetype exclusions (can be overridden in user config)
  exclusions = {
    -- Essential filetypes where completions should be disabled
    filetypes = {
      "help",
      "qf", -- quickfix  
    },
    -- Essential buffer patterns to exclude
    buffer_patterns = {
      "^term://",
      "^%[Command Line%]",
    },
    -- Essential buffer types to exclude
    buftypes = {
      "help",
      "quickfix", 
      "terminal",
      "prompt",
    },
  },

  -- Authentication configuration
  auth = {
    methods = { "keyring", "encrypted_file", "environment", "config", "prompt" },
    validate_on_startup = true,
    cache_validation = true,
  },

  -- LSP integration
  workspace_root = {
    use_lsp = true,
    find_root = nil,
    paths = {
      ".git",
      ".svn",
      ".hg",
      "package.json",
      "Cargo.toml",
      "pyproject.toml",
      "go.mod",
      "requirements.txt",
    },
  },
}

local config = {}
local namespace_id = vim.api.nvim_create_namespace("mistral_codestral")

-- Constants for context extraction
local CONTEXT_MAX_LINES = 100 -- Maximum lines of context to include
local CONTEXT_MIN_LINES = 20 -- Minimum lines of context to include
local CONTEXT_SIZE_RATIO = 4 -- Ratio of file size to context (1/4 of file)

-- Constants for floating window detection
local MIN_POPUP_WIDTH = 20 -- Minimum width for popup windows
local MIN_POPUP_HEIGHT = 3 -- Minimum height for popup windows

-- Debug logging function
local function debug_log(message, level)
  if config.debug then
    level = level or vim.log.levels.DEBUG
    vim.notify("[Mistral Codestral] " .. message, level)
  end
end

-- Validate exclusion patterns
local function validate_exclusion_patterns()
  if not config.exclusions then
    return true
  end
  
  local valid = true
  
  -- Check buffer_patterns for valid regex
  if config.exclusions.buffer_patterns then
    for i, pattern in ipairs(config.exclusions.buffer_patterns) do
      local ok = pcall(function()
        string.match("test", pattern)
      end)
      
      if not ok then
        debug_log("Invalid regex pattern in buffer_patterns[" .. i .. "]: " .. pattern, vim.log.levels.WARN)
        valid = false
      end
    end
  end
  
  -- Log configuration for debugging
  debug_log("Exclusion configuration loaded:")
  debug_log("  - Filetypes: " .. (#(config.exclusions.filetypes or {})) .. " entries")
  debug_log("  - Buffer patterns: " .. (#(config.exclusions.buffer_patterns or {})) .. " entries") 
  debug_log("  - Buffer types: " .. (#(config.exclusions.buftypes or {})) .. " entries")
  
  return valid
end

-- LSP workspace root detection
local function find_workspace_root()
  if config.workspace_root.find_root then
    local root = config.workspace_root.find_root()
    if root then
      return root
    end
  end

  if config.workspace_root.use_lsp then
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if clients and #clients > 0 then
      local workspace_folders = clients[1].config.workspace_folders
      if workspace_folders and #workspace_folders > 0 then
        return workspace_folders[1].name
      end
      if clients[1].config.root_dir then
        return clients[1].config.root_dir
      end
    end
  end

  -- Fallback: search for workspace indicators
  local current_dir = vim.fn.expand("%:p:h")
  local function find_root(path)
    for _, indicator in ipairs(config.workspace_root.paths) do
      if vim.fn.glob(path .. "/" .. indicator) ~= "" then
        return path
      end
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      return nil
    end
    return find_root(parent)
  end

  return find_root(current_dir) or current_dir
end

-- Get buffer language from LSP or filetype
local function get_buffer_language()
  -- Try to get language from LSP
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if clients and #clients > 0 then
    local client = clients[1]
    if client.config.filetypes then
      return client.config.filetypes[1]
    end
  end

  -- Fallback to filetype
  return vim.bo.filetype
end

-- Cache for buffer exclusion results to improve performance
local exclusion_cache = {}
local cache_invalidation_autocmd = nil

-- Clear exclusion cache for a specific buffer or all buffers
local function clear_exclusion_cache(bufnr)
  if bufnr then
    exclusion_cache[bufnr] = nil
  else
    exclusion_cache = {}
  end
end

-- Initialize cache invalidation autocmd
local function setup_cache_invalidation()
  if cache_invalidation_autocmd then
    return -- Already setup
  end
  
  cache_invalidation_autocmd = vim.api.nvim_create_augroup("MistralCodestralExclusionCache", { clear = true })
  
  -- Clear cache when buffer properties change
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost", "FileType" }, {
    group = cache_invalidation_autocmd,
    callback = function(ev)
      clear_exclusion_cache(ev.buf)
    end,
  })
  
  -- Clear cache when buffers are deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = cache_invalidation_autocmd,
    callback = function(ev)
      clear_exclusion_cache(ev.buf)
    end,
  })
end

-- Helper: Check if filetype should be excluded
local function is_filetype_excluded(filetype)
  if not config.exclusions or not config.exclusions.filetypes then
    return false
  end

  for _, excluded_ft in ipairs(config.exclusions.filetypes) do
    if filetype == excluded_ft then
      return true
    end
  end

  return false
end

-- Helper: Check if buftype should be excluded
local function is_buftype_excluded(buftype)
  if not config.exclusions or not config.exclusions.buftypes then
    return false
  end

  for _, excluded_bt in ipairs(config.exclusions.buftypes) do
    if buftype == excluded_bt then
      return true
    end
  end

  return false
end

-- Helper: Check if buffer name matches exclusion patterns
local function is_buffer_name_excluded(bufname)
  if not config.exclusions or not config.exclusions.buffer_patterns or not bufname or bufname == "" then
    return false
  end

  local relative_name = vim.fn.fnamemodify(bufname, ":t")

  for _, pattern in ipairs(config.exclusions.buffer_patterns) do
    local match_found = false

    -- Safely attempt pattern matching
    pcall(function()
      if string.match(relative_name, pattern) or string.match(bufname, pattern) then
        match_found = true
      end
    end)

    if match_found then
      return true, pattern, relative_name
    end
  end

  return false
end

-- Helper: Check if buffer is a floating window that should be excluded
local function is_floating_window_excluded(bufnr, bufname)
  local winid = vim.fn.bufwinid(bufnr)
  if winid == -1 then
    return false
  end

  local ok, win_config = pcall(vim.api.nvim_win_get_config, winid)
  if not ok or win_config.relative == "" then
    return false
  end

  -- Check if it's a popup/menu style floating window
  if win_config.focusable == false or
     win_config.style == "minimal" or
     (win_config.width and win_config.width < MIN_POPUP_WIDTH) or
     (win_config.height and win_config.height < MIN_POPUP_HEIGHT) then
    return true
  end

  -- Check for common popup buffer names
  if bufname and bufname ~= "" then
    local popup_patterns = { "completion", "hover", "signature", "diagnostic" }
    for _, popup_pattern in ipairs(popup_patterns) do
      if string.match(bufname:lower(), popup_pattern) then
        return true
      end
    end
  end

  return false
end

-- Check if current buffer should be excluded from completions
local function is_buffer_excluded(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  -- Validate buffer number
  if not bufnr or bufnr < 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
  
  -- Check cache first
  local cached_result = exclusion_cache[bufnr]
  if cached_result ~= nil then
    return cached_result
  end
  
  -- Check if mistral is globally disabled
  if not config.enabled then
    exclusion_cache[bufnr] = true
    return true
  end
  
  -- Get buffer information with error handling
  local ok, filetype = pcall(function() return vim.bo[bufnr].filetype end)
  if not ok then
    exclusion_cache[bufnr] = true
    return true
  end
  
  local buftype = ""
  local bufname = ""
  
  pcall(function()
    buftype = vim.bo[bufnr].buftype
    bufname = vim.api.nvim_buf_get_name(bufnr)
  end)
  
  -- Check excluded filetypes
  if is_filetype_excluded(filetype) then
    debug_log("Buffer " .. bufnr .. " excluded by filetype: " .. filetype)
    exclusion_cache[bufnr] = true
    return true
  end

  -- Check excluded buffer types
  if is_buftype_excluded(buftype) then
    debug_log("Buffer " .. bufnr .. " excluded by buftype: " .. buftype)
    exclusion_cache[bufnr] = true
    return true
  end

  -- Check buffer name patterns
  local name_excluded, pattern, matched_name = is_buffer_name_excluded(bufname)
  if name_excluded then
    debug_log("Buffer " .. bufnr .. " excluded by pattern: " .. pattern .. " (matched: " .. matched_name .. ")")
    exclusion_cache[bufnr] = true
    return true
  end

  -- Check for excluded floating windows
  if is_floating_window_excluded(bufnr, bufname) then
    debug_log("Buffer " .. bufnr .. " excluded as floating window")
    exclusion_cache[bufnr] = true
    return true
  end
  
  -- Cache the negative result
  exclusion_cache[bufnr] = false
  return false
end

-- Enhanced context extraction with LSP awareness
local function get_fim_context_enhanced()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  -- Get buffer info
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filetype = get_buffer_language()
  local workspace_root = find_workspace_root()
  local relative_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")

  -- Calculate smart context window based on file size
  local total_lines = #lines
  local context_size = math.min(CONTEXT_MAX_LINES, math.max(CONTEXT_MIN_LINES, total_lines / CONTEXT_SIZE_RATIO))
  local start_line = math.max(0, row - context_size)
  local end_line = math.min(total_lines - 1, row + context_size)

  -- Build prefix
  local prefix_lines = {}
  for i = start_line + 1, row do
    table.insert(prefix_lines, lines[i] or "")
  end

  if row + 1 <= total_lines then
    local current_line = lines[row + 1] or ""
    local line_prefix = string.sub(current_line, 1, col)
    if #prefix_lines > 0 then
      prefix_lines[#prefix_lines + 1] = line_prefix
    else
      prefix_lines[1] = line_prefix
    end
  end

  -- Build suffix
  local suffix_lines = {}
  if row + 1 <= total_lines then
    local current_line = lines[row + 1] or ""
    local line_suffix = string.sub(current_line, col + 1)
    if line_suffix ~= "" then
      table.insert(suffix_lines, line_suffix)
    end
  end

  for i = row + 2, math.min(end_line + 1, total_lines) do
    table.insert(suffix_lines, lines[i] or "")
  end

  local prefix = table.concat(prefix_lines, "\n")
  local suffix = table.concat(suffix_lines, "\n")

  return {
    prefix = prefix,
    suffix = suffix,
    filetype = filetype,
    relative_path = relative_path,
    workspace_root = workspace_root,
  }
end

-- HTTP request function (now uses centralized HTTP client)
local function make_request(data, callback)
  local auth = require("mistral-codestral.auth")
  local http_client = require("mistral-codestral.http_client")
  local api_key = auth.get_api_key()

  if not api_key then
    callback(nil, "API key not found. Set MISTRAL_API_KEY environment variable or configure api_key")
    return
  end

  http_client.post("https://codestral.mistral.ai/v1/fim/completions", {
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. api_key,
    },
    data = data,
    timeout = config.timeout,
  }, callback)
end

-- Request completion
local function request_completion(callback, context_override)
  local context = context_override or get_fim_context_enhanced()

  local request_data = {
    model = config.model,
    prompt = context.prefix,
    suffix = context.suffix,
    max_tokens = config.max_tokens,
    temperature = config.temperature,
    stop = config.stop_tokens,
  }

  make_request(request_data, function(response, error)
    if error then
      vim.notify("Mistral Codestral error: " .. error, vim.log.levels.ERROR)
      callback(nil)
      return
    end

    if response and response.choices and response.choices[1] then
      -- FIM API can return text in either choices[i].text or choices[i].message.content
      local choice = response.choices[1]
      local completion = choice.text or (choice.message and choice.message.content)
      callback(completion)
    else
      callback(nil)
    end
  end)
end

-- Insert completion function
local function insert_completion(completion)
  if not completion or completion == "" then
    return
  end

  -- Schedule the insertion to avoid E565 error in callback context
  vim.schedule(function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1
    local col = cursor[2]
    local bufnr = vim.api.nvim_get_current_buf()

    local completion_lines = vim.split(completion, "\n", { plain = true })

    if #completion_lines == 1 then
      -- Single line insertion - use nvim_put for simplicity
      vim.api.nvim_put({ completion_lines[1] }, "c", true, true)
    else
      -- Multi-line insertion - need careful cursor positioning
      local current_line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
      local line_prefix = string.sub(current_line, 1, col)
      local line_suffix = string.sub(current_line, col + 1)

      local new_lines = {}
      -- First line: prefix + first completion line
      table.insert(new_lines, line_prefix .. completion_lines[1])
      
      -- Middle lines: as-is
      for i = 2, #completion_lines - 1 do
        table.insert(new_lines, completion_lines[i])
      end
      
      -- Last line: last completion line + original suffix
      if #completion_lines > 1 then
        table.insert(new_lines, completion_lines[#completion_lines] .. line_suffix)
      end

      -- Replace the current line with all new lines
      vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, new_lines)
      
      -- Calculate final cursor position more precisely
      local final_row = row + #completion_lines - 1
      local final_col
      
      if #completion_lines == 1 then
        -- Single line: cursor after inserted text
        final_col = col + string.len(completion_lines[1])
      else
        -- Multi-line: cursor at end of last completion line (before suffix)
        final_col = string.len(completion_lines[#completion_lines])
      end
      
      -- Ensure cursor position is valid
      local final_line = vim.api.nvim_buf_get_lines(bufnr, final_row, final_row + 1, false)[1] or ""
      final_col = math.min(final_col, string.len(final_line))
      
      vim.api.nvim_win_set_cursor(0, { final_row + 1, final_col })
    end
  end)
end

-- Main completion function
local function complete()
  request_completion(function(completion)
    if completion then
      insert_completion(completion)
    end
  end)
end

-- Setup function
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", default_config, user_config or {})

  -- Initialize cache invalidation for performance
  setup_cache_invalidation()

  -- Validate exclusion patterns
  if not validate_exclusion_patterns() then
    vim.notify("Some exclusion patterns are invalid. Check configuration.", vim.log.levels.WARN)
  end

  debug_log("Mistral Codestral setup completed with debug logging enabled")

  -- Initialize auth module
  require("mistral-codestral.auth").setup(config.auth)

  -- Setup completion engine integration (blink.cmp v1.6+ or nvim-cmp)
  if config.enable_cmp_source then
    local blink_ok, blink = pcall(require, "mistral-codestral.blink")
    if blink_ok then
      blink.setup_completion_engine(config)
    else
      vim.notify("Failed to load completion engine integration", vim.log.levels.ERROR)
    end
  end

  -- Setup virtual text if enabled
  if config.virtual_text.enabled then
    local ok, virtual_text = pcall(require, "mistral-codestral.virtual_text")
    if ok then
      virtual_text.setup(config)
    end
  end

  -- Create user commands
  vim.api.nvim_create_user_command("MistralCodestralComplete", complete, {
    desc = "Get code completion from Mistral Codestral",
  })

  vim.api.nvim_create_user_command("MistralCodestralToggle", function()
    config.enabled = not config.enabled
    vim.notify("Mistral Codestral " .. (config.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
  end, {
    desc = "Toggle Mistral Codestral completions",
  })
end

-- Export functions
M.complete = complete
M.request_completion = request_completion
M.insert_completion = insert_completion
M.get_fim_context_enhanced = get_fim_context_enhanced
M.is_buffer_excluded = is_buffer_excluded
M.config = function()
  return config
end

return M
