-- lua/mistral-codestral/blink.lua
-- blink.cmp source for Mistral Codestral

local M = {}

-- Cache for completions
local completion_cache = {}
local cache_timeout = 5000 -- 5 seconds

local function generate_cache_key(context, cursor)
  -- Extract prefix and suffix from blink.cmp context
  local prefix = context.line:sub(1, context.bounds.start_col + context.bounds.length - 1)
  local suffix = context.line:sub(context.bounds.start_col + context.bounds.length)
  local filetype = vim.bo[context.bufnr].filetype
  
  return vim.fn.sha256(
    prefix:sub(-200)
      .. "|"
      .. suffix:sub(1, 200)
      .. "|"
      .. filetype
      .. "|"
      .. context.cursor[1]
      .. ","
      .. context.cursor[2]
  )
end

local function get_cached_items(key)
  local cached = completion_cache[key]
  if cached and (vim.loop.now() - cached.timestamp) < cache_timeout then
    return cached.items
  end
  return nil
end

local function set_cached_items(key, items)
  completion_cache[key] = {
    items = items,
    timestamp = vim.loop.now(),
  }
end

-- Blink.cmp source implementation
local BlinkSource = {}
BlinkSource.__index = BlinkSource

function BlinkSource.new()
  return setmetatable({}, BlinkSource)
end

function BlinkSource:get_completions(context, callback)
  -- Debug info
  local mistral = require("mistral-codestral")
  local mistral_config = mistral.config()

  -- Early return if disabled
  if not mistral_config or not mistral_config.enable_cmp_source then
    callback({ items = {} })
    return
  end

  -- Check if buffer should be excluded (includes all filetype and buffer checks)
  if mistral.is_buffer_excluded(context.bufnr) then
    callback({ items = {} })
    return
  end

  -- Generate cache key
  local cache_key = generate_cache_key(context, context.cursor)

  -- Check cache
  local cached_items = get_cached_items(cache_key)
  if cached_items then
    callback({ items = cached_items })
    return
  end

  -- Get enhanced context using LSP utils
  local lsp_utils = require("mistral-codestral.lsp_utils")
  local enhanced_context = lsp_utils.get_enhanced_context()

  -- Determine completion strategy
  local cursor_context = lsp_utils.get_cursor_context()
  local strategy = "normal"

  if cursor_context.in_comment then
    strategy = "comment_based"
  elseif cursor_context.in_function then
    strategy = "function_body"
  elseif context.trigger and context.trigger.kind == "trigger_character" then
    strategy = "triggered"
  end

  -- Request completion from Mistral
  mistral.request_completion(function(completion)
    if not completion or completion == "" then
      callback({ items = {} })
      return
    end

    local items = M.create_blink_items(completion, enhanced_context, strategy, mistral_config)

    -- Cache results
    set_cached_items(cache_key, items)

    callback({ items = items })
  end, enhanced_context)
end

-- Create blink.cmp compatible items
function M.create_blink_items(completion, context, strategy, config)
  local items = {}
  local lines = vim.split(completion, "\n", { plain = true })

  -- Main completion item
  local main_item = {
    label = completion:gsub("\n", " ⏎ "):sub(1, 60) .. (#lines > 1 and "..." or ""),
    insertText = completion,
    kind = #lines > 1 and require("blink.cmp.types").CompletionItemKind.Snippet
      or require("blink.cmp.types").CompletionItemKind.Text,
    detail = string.format("Codestral • %s • %d lines", strategy, #lines),
    source_name = "mistral_codestral",
    documentation = {
      kind = "markdown",
      value = string.format(
        "```%s\n%s\n```\n\n**Strategy**: %s  \n**Lines**: %d",
        context.filetype or "",
        completion,
        strategy,
        #lines
      ),
    },
    source_name = "mistral_codestral",
    source_id = "mistral_codestral_full",
    score_offset = 10, -- Lowered from 100 to not dominate
    sortText = "50_codestral_full", -- Moved from 00_ to 50_ for lower priority
    filterText = completion:gsub("\n", " "),
  }
  table.insert(items, main_item)

  -- Additional variants for multi-line completions (only if we have room for more items)
  -- Skip variants if max_items is 1 to avoid dominance
  local max_items_limit = config.cmp_max_items or 3
  if max_items_limit > 1 and #lines > 1 and #items < max_items_limit then
    -- First line variant
    local first_line_item = {
      label = "🤖 " .. lines[1],
      insertText = lines[1],
      kind = require("blink.cmp.types").CompletionItemKind.Text,
      detail = "Codestral • first line",
      documentation = {
        kind = "markdown",
        value = string.format("```%s\n%s\n```\n\n**Type**: First line only", context.filetype or "", lines[1]),
      },
      source_name = "mistral_codestral",
      source_id = "mistral_codestral_line",
      score_offset = 5, -- Lowered from 90
      sortText = "51_codestral_line", -- Lowered priority
    }
    table.insert(items, first_line_item)

    -- Two lines variant
    if #lines > 2 and #items < max_items_limit then
      local two_lines = table.concat({ lines[1], lines[2] }, "\n")
      local two_lines_item = {
        label = "🤖 " .. lines[1] .. " ⏎ " .. lines[2]:sub(1, 30) .. "...",
        insertText = two_lines,
        kind = require("blink.cmp.types").CompletionItemKind.Snippet,
        detail = "Codestral • 2 lines",
        documentation = {
          kind = "markdown",
          value = string.format("```%s\n%s\n```\n\n**Type**: Two lines", context.filetype or "", two_lines),
        },
        source_name = "mistral_codestral",
        source_id = "mistral_codestral_two_lines",
        score_offset = 0, -- Lowered from 85
        sortText = "52_codestral_two_lines", -- Lowered priority
      }
      table.insert(items, two_lines_item)
    end
  end

  return items
end

-- Check if blink.cmp is available and compatible
local function is_blink_available()
  local ok, blink = pcall(require, "blink.cmp")
  return ok
end

-- Register the blink.cmp source (v1.6 compatible)
function M.register(mistral_config)
  if not is_blink_available() then
    return false
  end

  -- For blink.cmp v1.6+, sources are configured in the main plugin config
  -- This function just verifies availability
  return true
end

-- Auto-detection and setup for both cmp engines
function M.setup_completion_engine(mistral_config)
  local nvim_cmp_ok = pcall(require, "cmp")
  local blink_cmp_ok = is_blink_available()

  local engines_configured = {}
  local engine_preference = mistral_config.completion_engine or "auto"

  -- Register with blink.cmp if available and preferred
  if
    blink_cmp_ok and (engine_preference == "auto" or engine_preference == "blink.cmp" or engine_preference == "both")
  then
    if M.register(mistral_config) then
      table.insert(engines_configured, "blink.cmp")
    end
  end

  -- Register with nvim-cmp if available and preferred
  if
    nvim_cmp_ok and (engine_preference == "auto" or engine_preference == "nvim-cmp" or engine_preference == "both")
  then
    -- Only register if blink.cmp wasn't the preferred choice
    if engine_preference == "nvim-cmp" or engine_preference == "both" or not blink_cmp_ok then
      local ok, cmp_source = pcall(require, "mistral-codestral.cmp_source_enhanced")
      if ok and cmp_source.register(mistral_config) then
        table.insert(engines_configured, "nvim-cmp")
      end
    end
  end

  if #engines_configured > 0 then
    local msg = "Mistral Codestral registered with: " .. table.concat(engines_configured, ", ")
    if #engines_configured > 1 then
      msg = msg .. " (both engines active - consider using only one for better performance)"
    end
    vim.notify(msg, vim.log.levels.INFO)
  else
    vim.notify("No compatible completion engines found (nvim-cmp or blink.cmp required)", vim.log.levels.WARN)
  end

  return engines_configured
end

-- Expose the source class for direct blink.cmp registration
M.BlinkSource = BlinkSource

-- For blink.cmp v1.6 compatibility, export the source class directly
M.new = BlinkSource.new
M.get_completions = function(self, context, callback)
  return BlinkSource.get_completions(self, context, callback)
end

return M
