-- lua/mistral-codestral/lsp_utils.lua
-- LSP integration utilities for enhanced context

local M = {}
local errors = require("mistral-codestral.errors")

-- Cache for LSP clients (reduces repeated get_active_clients calls)
local client_cache = {
  bufnr = nil,
  clients = nil,
  timestamp = 0,
}

-- Cache TTL in milliseconds (100ms is reasonable for LSP client changes)
local CACHE_TTL = 100

-- Get cached LSP clients for buffer
-- @param bufnr number Buffer number
-- @return table List of LSP clients
local function get_cached_clients(bufnr)
  local now = vim.loop.now()

  -- Return cached clients if still valid
  if client_cache.bufnr == bufnr and
     client_cache.clients and
     (now - client_cache.timestamp) < CACHE_TTL then
    return client_cache.clients
  end

  -- Fetch fresh clients
  local ok, clients = pcall(vim.lsp.get_active_clients, { bufnr = bufnr })
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to get LSP clients", { error = clients })
    return {}
  end

  -- Update cache
  client_cache.bufnr = bufnr
  client_cache.clients = clients or {}
  client_cache.timestamp = now

  return client_cache.clients
end

-- Clear client cache (call when buffer changes significantly)
function M.clear_cache()
  client_cache.bufnr = nil
  client_cache.clients = nil
  client_cache.timestamp = 0
end

-- Get LSP diagnostics for context
local function get_lsp_diagnostics()
  local ok, bufnr = pcall(vim.api.nvim_get_current_buf)
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to get current buffer")
    return { errors = {}, warnings = {}, hints = {} }
  end

  local diag_ok, diagnostics = pcall(vim.diagnostic.get, bufnr)
  if not diag_ok or not diagnostics then
    return { errors = {}, warnings = {}, hints = {} }
  end

  -- Pre-allocate tables for better performance
  local diagnostic_info = {
    errors = {},
    warnings = {},
    hints = {},
  }

  for _, diagnostic in ipairs(diagnostics) do
    local severity = diagnostic.severity
    local message = diagnostic.message
    local line = diagnostic.lnum + 1 -- Convert to 1-indexed

    local diag_entry = {
      line = line,
      message = message,
      source = diagnostic.source,
    }

    if severity == vim.diagnostic.severity.ERROR then
      table.insert(diagnostic_info.errors, diag_entry)
    elseif severity == vim.diagnostic.severity.WARN then
      table.insert(diagnostic_info.warnings, diag_entry)
    elseif severity == vim.diagnostic.severity.HINT then
      table.insert(diagnostic_info.hints, diag_entry)
    end
  end

  return diagnostic_info
end

-- Get LSP symbols for context
local function get_lsp_symbols()
  local ok, bufnr = pcall(vim.api.nvim_get_current_buf)
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to get current buffer for symbols")
    return {}
  end

  local clients = get_cached_clients(bufnr)

  if not clients or #clients == 0 then
    return {}
  end

  local symbols = {}

  -- Get document symbols from LSP
  for _, client in ipairs(clients) do
    if client.server_capabilities and client.server_capabilities.documentSymbolProvider then
      local params_ok, params = pcall(function()
        return { textDocument = vim.lsp.util.make_text_document_params() }
      end)

      if params_ok then
        client.request("textDocument/documentSymbol", params, function(err, result)
          if err then
            errors.debug(errors.CATEGORY.INTERNAL, "LSP symbol request failed", { error = err })
            return
          end

          if result then
            for _, symbol in ipairs(result) do
              table.insert(symbols, {
                name = symbol.name,
                kind = symbol.kind,
                range = symbol.range,
                detail = symbol.detail,
              })
            end
          end
        end)
      end
    end
  end

  return symbols
end

-- Get current function/class context from LSP
local function get_current_context()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1

  local symbols = get_lsp_symbols()
  local current_function = nil
  local current_class = nil

  for _, symbol in ipairs(symbols) do
    local start_line = symbol.range.start.line
    local end_line = symbol.range["end"].line

    if start_line <= row and row <= end_line then
      if symbol.kind == 12 then -- Function
        current_function = symbol.name
      elseif symbol.kind == 5 then -- Class
        current_class = symbol.name
      end
    end
  end

  return {
    function_name = current_function,
    class_name = current_class,
  }
end

-- Get related imports and dependencies
local function get_imports_context()
  local ok, bufnr = pcall(vim.api.nvim_get_current_buf)
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to get buffer for imports")
    return {}
  end

  local lines_ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, 50, false)
  if not lines_ok or not lines then
    return {}
  end

  -- Pre-allocate imports table with estimated size
  local imports = {}
  local filetype = vim.bo.filetype

  for _, line in ipairs(lines) do
    if filetype == "python" then
      local import_match = line:match("^import%s+(.+)") or line:match("^from%s+(.+)%s+import")
      if import_match then
        table.insert(imports, line)
      end
    elseif filetype == "javascript" or filetype == "typescript" then
      if line:match("^import") or line:match("^const.*require") then
        table.insert(imports, line)
      end
    elseif filetype == "rust" then
      if line:match("^use%s+") then
        table.insert(imports, line)
      end
    elseif filetype == "go" then
      if line:match("^import") then
        table.insert(imports, line)
      end
    end
  end

  return imports
end

-- Enhanced context for LSP-aware completions
function M.get_enhanced_context()
  local base_context = require("mistral-codestral").get_fim_context_enhanced()

  -- Add LSP information
  local diagnostics = get_lsp_diagnostics()
  local current_context = get_current_context()
  local imports = get_imports_context()

  -- Enhance prefix with relevant context
  local enhanced_prefix = base_context.prefix

  -- Add import context if relevant
  if #imports > 0 then
    local import_context = "// Imports:\n" .. table.concat(imports, "\n") .. "\n\n"
    enhanced_prefix = import_context .. enhanced_prefix
  end

  -- Add function/class context
  if current_context.class_name then
    enhanced_prefix = "// In class: " .. current_context.class_name .. "\n" .. enhanced_prefix
  end
  if current_context.function_name then
    enhanced_prefix = "// In function: " .. current_context.function_name .. "\n" .. enhanced_prefix
  end

  return vim.tbl_extend("force", base_context, {
    prefix = enhanced_prefix,
    diagnostics = diagnostics,
    current_context = current_context,
    imports = imports,
  })
end

-- LSP hover integration for better completions
function M.get_hover_info(callback)
  if type(callback) ~= "function" then
    errors.error(errors.CATEGORY.INTERNAL, "get_hover_info requires a callback function")
    return
  end

  local ok, params = pcall(vim.lsp.util.make_position_params)
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to create hover params")
    callback(nil)
    return
  end

  vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
    if err then
      errors.debug(errors.CATEGORY.INTERNAL, "LSP hover request failed", { error = err })
      callback(nil)
      return
    end

    if result and result.contents then
      local hover_content = ""
      if type(result.contents) == "string" then
        hover_content = result.contents
      elseif result.contents.value then
        hover_content = result.contents.value
      end
      callback(hover_content)
    else
      callback(nil)
    end
  end)
end

-- Get signature help for function context
function M.get_signature_help(callback)
  if type(callback) ~= "function" then
    errors.error(errors.CATEGORY.INTERNAL, "get_signature_help requires a callback function")
    return
  end

  local ok, params = pcall(vim.lsp.util.make_position_params)
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to create signature params")
    callback(nil)
    return
  end

  vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result)
    if err then
      errors.debug(errors.CATEGORY.INTERNAL, "LSP signature help request failed", { error = err })
      callback(nil)
      return
    end

    if result and result.signatures then
      local signatures = {}
      for _, sig in ipairs(result.signatures) do
        table.insert(signatures, {
          label = sig.label,
          documentation = sig.documentation,
          parameters = sig.parameters,
        })
      end
      callback(signatures)
    else
      callback(nil)
    end
  end)
end

-- Check if cursor is in a specific LSP context (function, class, etc.)
function M.get_cursor_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    position = { line = row, character = col },
  }

  local context = {
    in_function = false,
    in_class = false,
    in_comment = false,
    in_string = false,
  }

  -- Use treesitter if available for more accurate context
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if ok then
    local node = ts_utils.get_node_at_cursor()
    if node then
      local node_type = node:type()
      context.in_function = node_type:match("function") ~= nil
      context.in_class = node_type:match("class") ~= nil
      context.in_comment = node_type:match("comment") ~= nil
      context.in_string = node_type:match("string") ~= nil
    end
  end

  return context
end

-- Get project-wide context from LSP workspace symbols
function M.get_workspace_symbols(query, callback)
  if type(callback) ~= "function" then
    errors.error(errors.CATEGORY.INTERNAL, "get_workspace_symbols requires a callback function")
    return
  end

  local params = { query = query or "" }

  vim.lsp.buf_request(0, "workspace/symbol", params, function(err, result)
    if err then
      errors.debug(errors.CATEGORY.INTERNAL, "LSP workspace symbols request failed", { error = err })
      callback({})
      return
    end

    if result then
      local symbols = {}
      for _, symbol in ipairs(result) do
        table.insert(symbols, {
          name = symbol.name,
          kind = symbol.kind,
          location = symbol.location,
          container_name = symbol.containerName,
        })
      end
      callback(symbols)
    else
      callback({})
    end
  end)
end

-- Integration with LSP completion for hybrid results
function M.get_lsp_completions(callback)
  if type(callback) ~= "function" then
    errors.error(errors.CATEGORY.INTERNAL, "get_lsp_completions requires a callback function")
    return
  end

  local ok, params = pcall(vim.lsp.util.make_position_params)
  if not ok then
    errors.warning(errors.CATEGORY.INTERNAL, "Failed to create completion params")
    callback({})
    return
  end

  params.context = {
    triggerKind = 1, -- Invoked
  }

  vim.lsp.buf_request(0, "textDocument/completion", params, function(err, result)
    if err then
      errors.debug(errors.CATEGORY.INTERNAL, "LSP completion request failed", { error = err })
      callback({})
      return
    end

    if result then
      local items = {}
      local completion_list = result.items or result

      for _, item in ipairs(completion_list) do
        table.insert(items, {
          label = item.label,
          kind = item.kind,
          detail = item.detail,
          documentation = item.documentation,
          insertText = item.insertText or item.label,
        })
      end

      callback(items)
    else
      callback({})
    end
  end)
end

-- Combine LSP and Mistral completions
function M.get_hybrid_completions(callback)
  local lsp_items = {}
  local mistral_completion = nil
  local completed = 0

  local function check_completion()
    completed = completed + 1
    if completed == 2 then
      -- Both LSP and Mistral completed
      callback({
        lsp_items = lsp_items,
        mistral_completion = mistral_completion,
      })
    end
  end

  -- Get LSP completions
  M.get_lsp_completions(function(items)
    lsp_items = items
    check_completion()
  end)

  -- Get Mistral completion
  require("mistral-codestral").request_completion(function(completion)
    mistral_completion = completion
    check_completion()
  end)
end

return M
