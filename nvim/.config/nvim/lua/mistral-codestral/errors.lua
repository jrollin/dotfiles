-- lua/mistral-codestral/errors.lua
-- Centralized error handling and reporting

local M = {}

-- Error severity levels
M.SEVERITY = {
  ERROR = "error",
  WARNING = "warning",
  INFO = "info",
  DEBUG = "debug",
}

-- Error categories for better organization
M.CATEGORY = {
  API = "api",
  AUTH = "auth",
  CONFIG = "config",
  NETWORK = "network",
  INTERNAL = "internal",
}

-- Configuration
local config = {
  debug = false,
  log_file = nil,
  notify_errors = true,
}

-- Configure error handling
-- @param opts table Configuration options
function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

-- Format error message with context
-- @param category string Error category
-- @param message string Error message
-- @param context table Optional context information
-- @return string Formatted error message
local function format_error(category, message, context)
  local parts = {"[mistral-codestral]"}

  if category then
    table.insert(parts, string.format("[%s]", category))
  end

  table.insert(parts, message)

  if context and next(context) then
    local context_str = vim.inspect(context):gsub("\n", " ")
    table.insert(parts, string.format("Context: %s", context_str))
  end

  return table.concat(parts, " ")
end

-- Log error to file if configured
-- @param severity string Error severity
-- @param message string Formatted error message
local function log_to_file(severity, message)
  if not config.log_file then
    return
  end

  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local log_entry = string.format("[%s] [%s] %s\n", timestamp, severity:upper(), message)

  local file = io.open(config.log_file, "a")
  if file then
    file:write(log_entry)
    file:close()
  end
end

-- Report error with appropriate notification
-- @param severity string Error severity level
-- @param category string Error category
-- @param message string Error message
-- @param context table Optional context
function M.report(severity, category, message, context)
  local formatted = format_error(category, message, context)

  -- Log to file if configured
  log_to_file(severity, formatted)

  -- Debug messages only shown in debug mode
  if severity == M.SEVERITY.DEBUG and not config.debug then
    return
  end

  -- Show notification if enabled
  if config.notify_errors then
    local notify_level = vim.log.levels.INFO

    if severity == M.SEVERITY.ERROR then
      notify_level = vim.log.levels.ERROR
    elseif severity == M.SEVERITY.WARNING then
      notify_level = vim.log.levels.WARN
    end

    vim.notify(formatted, notify_level)
  end
end

-- Convenience functions for different severity levels
function M.error(category, message, context)
  M.report(M.SEVERITY.ERROR, category, message, context)
end

function M.warning(category, message, context)
  M.report(M.SEVERITY.WARNING, category, message, context)
end

function M.info(category, message, context)
  M.report(M.SEVERITY.INFO, category, message, context)
end

function M.debug(category, message, context)
  M.report(M.SEVERITY.DEBUG, category, message, context)
end

-- Wrap function with error handling
-- @param fn function Function to wrap
-- @param category string Error category
-- @param error_message string Error message template
-- @return function Wrapped function
function M.wrap(fn, category, error_message)
  return function(...)
    local ok, result = pcall(fn, ...)
    if not ok then
      M.error(category, error_message or "Operation failed", {
        error = tostring(result)
      })
      return nil
    end
    return result
  end
end

-- Parse API error response
-- @param response table API response
-- @return string|nil Error message if error exists
function M.parse_api_error(response)
  if not response then
    return "Empty API response"
  end

  -- Standard API error format
  if response.error then
    local msg = "API Error"
    if response.error.type then
      msg = msg .. " (" .. response.error.type .. ")"
    end
    if response.error.message then
      msg = msg .. ": " .. response.error.message
    end
    return msg
  end

  -- Validation error format (422)
  if response.detail then
    local msg = "Validation Error"
    if type(response.detail) == "string" then
      msg = msg .. ": " .. response.detail
    elseif type(response.detail) == "table" and response.detail[1] then
      msg = msg .. ": " .. (response.detail[1].msg or "Invalid request")
    end
    return msg
  end

  return nil
end

-- Parse HTTP error from exit code
-- @param exit_code number curl exit code
-- @param timeout number Request timeout in ms
-- @return string Error message
function M.parse_http_error(exit_code, timeout)
  if exit_code == 28 then
    return string.format("Request timeout after %d seconds", math.floor(timeout / 1000))
  elseif exit_code == 6 then
    return "Could not resolve host (check network connection)"
  elseif exit_code == 7 then
    return "Failed to connect to server"
  elseif exit_code == 35 then
    return "SSL connection error"
  elseif exit_code == 52 then
    return "Server returned nothing (empty response)"
  elseif exit_code == 56 then
    return "Network error receiving data"
  else
    return string.format("Request failed with exit code: %d", exit_code)
  end
end

return M
