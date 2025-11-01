-- lua/mistral-codestral/http_client.lua
-- Centralized HTTP client for API requests

local M = {}
local errors = require("mistral-codestral.errors")

-- Helper: Wrap async operation with timeout
-- @param fn function The async operation (receives callback as parameter)
-- @param timeout_ms number Timeout in milliseconds
-- @param on_timeout function Called when timeout occurs
local function with_timeout(fn, timeout_ms, on_timeout)
  local timer = vim.loop.new_timer()
  local completed = false

  timer:start(timeout_ms, 0, vim.schedule_wrap(function()
    if not completed then
      completed = true
      timer:stop()
      timer:close()
      on_timeout()
    end
  end))

  fn(function(...)
    if not completed then
      completed = true
      timer:stop()
      timer:close()
      -- Continue with original callback
      return ...
    end
  end)
end

-- Make an HTTP POST request using curl
-- @param url string The URL to request
-- @param options table {
--   headers: table of header key-value pairs
--   data: table to be JSON encoded
--   timeout: number timeout in milliseconds (default 10000)
-- }
-- @param callback function(response, error) Called with response or error
-- Note: Timeout is enforced by curl's --max-time flag. If the request takes
-- longer than timeout, callback will be called with error containing "timeout"
function M.post(url, options, callback)
  options = options or {}
  local headers = options.headers or {}
  local data = options.data
  local timeout = options.timeout or 10000

  -- Encode data as JSON
  local json_data = vim.fn.json_encode(data)
  local temp_file = vim.fn.tempname()
  vim.fn.writefile({ json_data }, temp_file)

  -- Build curl command
  local curl_cmd = {
    "curl",
    "-s",
    "-X",
    "POST",
    "-d",
    "@" .. temp_file,
    "--max-time",
    tostring(math.floor(timeout / 1000)),
  }

  -- Add headers
  for key, value in pairs(headers) do
    table.insert(curl_cmd, "-H")
    table.insert(curl_cmd, key .. ": " .. value)
  end

  -- Add URL as last argument
  table.insert(curl_cmd, url)

  -- Execute request with timeout handling
  local job_id = vim.fn.jobstart(curl_cmd, {
    on_exit = function(_, exit_code)
      vim.fn.delete(temp_file)
      if exit_code ~= 0 then
        local error_msg = errors.parse_http_error(exit_code, timeout)
        errors.warning(errors.CATEGORY.NETWORK, error_msg, { exit_code = exit_code })
        callback(nil, error_msg)
      end
    end,
    stdout_buffered = true,
    on_stdout = function(_, output_data)
      if output_data and output_data[1] and output_data[1] ~= "" then
        local response_text = table.concat(output_data, "\n")
        local ok, response = pcall(vim.fn.json_decode, response_text)

        if ok and response then
          -- Check for API error responses using centralized parser
          local api_error = errors.parse_api_error(response)
          if api_error then
            errors.error(errors.CATEGORY.API, api_error)
            callback(nil, api_error)
          else
            callback(response, nil)
          end
        else
          local error_msg = "Failed to parse JSON response"
          errors.error(errors.CATEGORY.API, error_msg, { response_text = response_text })
          callback(nil, error_msg)
        end
      end
    end,
  })

  -- Check if job started successfully
  if job_id <= 0 then
    vim.fn.delete(temp_file)
    local error_msg = "Failed to start HTTP request job"
    errors.error(errors.CATEGORY.INTERNAL, error_msg, { job_id = job_id })
    callback(nil, error_msg)
  end
end

-- Validate API key (makes a minimal test request)
-- @param api_key string The API key to validate
-- @param callback function(valid, error_message)
function M.validate_api_key(api_key, callback)
  if type(callback) ~= "function" then
    errors.error(errors.CATEGORY.INTERNAL, "validate_api_key requires a callback function")
    return
  end

  if not api_key then
    local error_msg = "No API key provided"
    errors.warning(errors.CATEGORY.AUTH, error_msg)
    callback(false, error_msg)
    return
  end

  -- Minimal test request
  local test_data = {
    model = "codestral-latest",
    prompt = "test",
    max_tokens = 1,
    temperature = 0.0,
  }

  M.post("https://codestral.mistral.ai/v1/fim/completions", {
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. api_key,
    },
    data = test_data,
    timeout = 5000,
  }, function(response, error)
    if error then
      callback(false, error)
      return
    end

    if response then
      -- Even if request params were invalid, if we got here the key is valid
      callback(true, nil)
    else
      callback(false, "Invalid response")
    end
  end)
end

return M
