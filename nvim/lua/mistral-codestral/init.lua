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

  -- Completion engine integration
  enable_cmp_source = true,
  cmp_max_items = 5,
  completion_engine = "blink.cmp", -- "auto", "nvim-cmp", "blink.cmp", "both"

  -- Virtual text configuration
  virtual_text = {
    enabled = false,
    manual = false,
    idle_delay = 200,
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
  local context_size = math.min(100, math.max(20, total_lines / 4))
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

-- HTTP request function
local function make_request(data, callback)
  local auth = require("mistral-codestral.auth")
  local api_key = auth.get_api_key()

  if not api_key then
    callback(nil, "API key not found. Set MISTRAL_API_KEY environment variable or configure api_key")
    return
  end

  local json_data = vim.fn.json_encode(data)
  local temp_file = vim.fn.tempname()
  vim.fn.writefile({ json_data }, temp_file)

  local curl_cmd = {
    "curl",
    "-s",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. api_key,
    "-d",
    "@" .. temp_file,
    "--max-time",
    tostring(config.timeout / 1000),
    "https://codestral.mistral.ai/v1/fim/completions",
  }

  vim.fn.jobstart(curl_cmd, {
    on_exit = function(_, exit_code)
      vim.fn.delete(temp_file)
      if exit_code ~= 0 then
        callback(nil, "Request failed with exit code: " .. exit_code)
      end
    end,
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and data[1] and data[1] ~= "" then
        local response_text = table.concat(data, "\n")
        local ok, response = pcall(vim.fn.json_decode, response_text)
        if ok and response then
          callback(response, nil)
        else
          callback(nil, "Failed to parse JSON response")
        end
      end
    end,
  })
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
      local completion = response.choices[1].message.content or response.choices[1].text
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

  -- Initialize auth module
  require("mistral-codestral.auth").setup(config.auth)

  -- Register nvim-cmp source
  if config.enable_cmp_source then
    local ok, cmp_source = pcall(require, "mistral-codestral.cmp_source")
    if ok then
      cmp_source.register(config)
    else
      -- Try enhanced version
      local ok2, cmp_enhanced = pcall(require, "mistral-codestral.cmp_source_enchanced")
      if ok2 then
        cmp_enhanced.register(config)
      else
        -- Try blink integration
        local ok3, blink = pcall(require, "mistral-codestral.blink")
        if ok3 then
          blink.setup_completion_engine(config)
        end
      end
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
M.config = function()
  return config
end

return M
