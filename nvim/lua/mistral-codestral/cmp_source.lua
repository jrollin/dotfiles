-- lua/mistral-codestral/cmp_source_enhanced.lua
-- Enhanced nvim-cmp source with LSP integration

local M = {}
local cmp = require("cmp")
local lsp_utils = require("mistral-codestral.lsp_utils")

local source = {}
source.new = function()
  return setmetatable({}, { __index = source })
end

-- Cache for completions to improve performance
local completion_cache = {}
local cache_timeout = 5000 -- 5 seconds

-- Generate cache key
local function generate_cache_key(context, request)
  local key_parts = {
    context.prefix:sub(-200), -- Last 200 chars of prefix
    context.suffix:sub(1, 200), -- First 200 chars of suffix
    context.filetype,
    request.option and request.option.reason or "unknown",
  }
  return table.concat(key_parts, "|")
end

-- Check cache
local function get_cached_completion(key)
  local cached = completion_cache[key]
  if cached and (vim.loop.now() - cached.timestamp) < cache_timeout then
    return cached.items
  end
  return nil
end

-- Set cache
local function set_cached_completion(key, items)
  completion_cache[key] = {
    items = items,
    timestamp = vim.loop.now(),
  }
end

function source:get_trigger_characters()
  return { ".", ":", "(", "[", "{", " ", "\n", "\t", "=", ",", ";" }
end

function source:get_keyword_pattern()
  return [[\k\+]]
end

function source:is_available()
  local mistral = require("mistral-codestral")
  local mistral_config = mistral.config()
  if not mistral_config or not mistral_config.enable_cmp_source then
    return false
  end

  -- Check if buffer should be excluded (includes all filetype and buffer checks)
  if mistral.is_buffer_excluded() then
    return false
  end

  return true
end

function source:complete(request, callback)
  local mistral = require("mistral-codestral")
  local mistral_config = mistral.config()

  -- Get enhanced context with LSP information
  local context = lsp_utils.get_enhanced_context()
  local cache_key = generate_cache_key(context, request)

  -- Check cache first
  local cached_items = get_cached_completion(cache_key)
  if cached_items then
    callback({ items = cached_items, isIncomplete = false })
    return
  end

  -- Determine completion strategy based on context
  local cursor_context = lsp_utils.get_cursor_context()
  local completion_strategy = "normal"

  if cursor_context.in_comment then
    completion_strategy = "comment_based"
  elseif cursor_context.in_function then
    completion_strategy = "function_body"
  elseif request.context and request.context.triggerKind == 2 then -- TriggerCharacter
    completion_strategy = "triggered"
  end

  -- Enhanced request with LSP context
  local enhanced_context = vim.tbl_extend("force", context, {
    strategy = completion_strategy,
    lsp_active = #vim.lsp.get_active_clients({ bufnr = 0 }) > 0,
  })

  -- For comment-based completions, we might want different parameters
  local request_params = {
    model = config.model,
    prompt = enhanced_context.prefix,
    suffix = enhanced_context.suffix,
    max_tokens = completion_strategy == "comment_based" and 512 or mistral_config.max_tokens,
    temperature = completion_strategy == "comment_based" and 0.2 or mistral_config.temperature,
    stop = mistral_config.stop_tokens,
  }

  -- Make request to Mistral
  mistral.request_completion(function(completion)
    if not completion or completion == "" then
      callback({ items = {}, isIncomplete = false })
      return
    end

    local items = M.create_cmp_items(completion, enhanced_context, completion_strategy)

    -- Cache the result
    set_cached_completion(cache_key, items)

    callback({
      items = items,
      isIncomplete = false,
    })
  end, enhanced_context)
end

-- Create nvim-cmp items from completion
function M.create_cmp_items(completion, context, strategy)
  local items = {}
  local lines = vim.split(completion, "\n", { plain = true })

  -- Primary completion (full text)
  local full_completion = {
    label = completion:gsub("\n", " ⏎ "):sub(1, 80) .. (#lines > 1 and "..." or ""),
    insertText = completion,
    kind = #lines > 1 and cmp.lsp.CompletionItemKind.Snippet or cmp.lsp.CompletionItemKind.Text,
    detail = string.format("Mistral Codestral (%d lines) • %s", #lines, strategy),
    documentation = {
      kind = "markdown",
      value = string.format("```%s\n%s\n```\n\n**Context**: %s strategy", context.filetype or "", completion, strategy),
    },
    data = {
      source = "mistral_codestral",
      type = "full",
      context = context,
    },
    sortText = "00_mistral_full",
    filterText = completion:gsub("\n", " "),
  }
  table.insert(items, full_completion)

  -- Additional variants for multi-line completions
  if #lines > 1 then
    -- First line only
    local first_line_item = {
      label = lines[1],
      insertText = lines[1],
      kind = cmp.lsp.CompletionItemKind.Text,
      detail = "Mistral Codestral (first line)",
      documentation = {
        kind = "markdown",
        value = string.format("```%s\n%s\n```", context.filetype or "", lines[1]),
      },
      data = {
        source = "mistral_codestral",
        type = "first_line",
      },
      sortText = "01_mistral_line",
    }
    table.insert(items, first_line_item)

    -- First two lines if available
    if #lines > 2 then
      local two_lines = table.concat({ lines[1], lines[2] }, "\n")
      local two_lines_item = {
        label = lines[1] .. " ⏎ " .. lines[2]:sub(1, 40) .. "...",
        insertText = two_lines,
        kind = cmp.lsp.CompletionItemKind.Snippet,
        detail = "Mistral Codestral (2 lines)",
        documentation = {
          kind = "markdown",
          value = string.format("```%s\n%s\n```", context.filetype or "", two_lines),
        },
        data = {
          source = "mistral_codestral",
          type = "two_lines",
        },
        sortText = "02_mistral_two_lines",
      }
      table.insert(items, two_lines_item)
    end
  end

  return items
end

-- Register enhanced source
function M.register(mistral_config)
  local ok, cmp_available = pcall(require, "cmp")
  if not ok or not cmp_available then
    vim.notify("nvim-cmp not available, skipping source registration", vim.log.levels.WARN)
    return
  end

  cmp.register_source("mistral_codestral", source.new())

  -- Try to auto-configure cmp sources
  vim.defer_fn(function()
    local current_config = cmp.get_config()
    if current_config and current_config.sources then
      local has_mistral = false
      for _, src in ipairs(current_config.sources) do
        if src.name == "mistral_codestral" then
          has_mistral = true
          break
        end
      end

      if not has_mistral then
        -- Add Mistral as a source with appropriate priority
        local sources = {
          { name = "nvim_lsp", priority = 1000 },
          { name = "mistral_codestral", priority = 700, max_item_count = mistral_config.cmp_max_items },
          { name = "luasnip", priority = 600 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 400 },
        }

        -- Merge with existing sources while avoiding duplicates
        local existing_sources = current_config.sources
        local merged_sources = {}
        local added = {}

        -- Add high priority sources first
        for _, src in ipairs(sources) do
          if not added[src.name] then
            table.insert(merged_sources, src)
            added[src.name] = true
          end
        end

        -- Add any remaining existing sources
        for _, src in ipairs(existing_sources) do
          if not added[src.name] then
            table.insert(merged_sources, src)
            added[src.name] = true
          end
        end

        cmp.setup.buffer({ sources = merged_sources })
      end
    end
  end, 100)
end

return M
