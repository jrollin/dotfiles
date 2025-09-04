-- lua/mistral-codestral/advanced.lua
-- Extended functionality for the Mistral Codestral plugin

local M = {}

-- Configuration for advanced features
local advanced_config = {
  enable_auto_completion = false,
  auto_trigger_chars = { ".", ":", "(", "[", "{" },
  debounce_delay = 500, -- ms
  show_progress = true,
  cache_completions = true,
  max_cache_size = 100,
}

local completion_cache = {}
local cache_order = {}
local debounce_timer = nil

-- Cache management
local function add_to_cache(key, completion)
  if not advanced_config.cache_completions then
    return
  end

  completion_cache[key] = completion
  table.insert(cache_order, key)

  -- Maintain cache size
  if #cache_order > advanced_config.max_cache_size then
    local oldest_key = table.remove(cache_order, 1)
    completion_cache[oldest_key] = nil
  end
end

local function get_from_cache(key)
  if not advanced_config.cache_completions then
    return nil
  end
  return completion_cache[key]
end

-- Generate cache key from context
local function generate_cache_key(prefix, suffix)
  -- Use last 100 chars of prefix and first 100 chars of suffix
  local prefix_key = string.sub(prefix, -100)
  local suffix_key = string.sub(suffix, 1, 100)
  return vim.fn.sha256(prefix_key .. "|" .. suffix_key)
end

-- Auto-completion on trigger characters
local function setup_auto_completion()
  if not advanced_config.enable_auto_completion then
    return
  end

  local group = vim.api.nvim_create_augroup("MistralCodestralAuto", { clear = true })

  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    callback = function()
      local char = vim.fn.nr2char(vim.fn.getchar(0))

      if vim.tbl_contains(advanced_config.auto_trigger_chars, char) then
        -- Debounce the completion request
        if debounce_timer then
          vim.fn.timer_stop(debounce_timer)
        end

        debounce_timer = vim.fn.timer_start(advanced_config.debounce_delay, function()
          require("mistral-codestral").complete()
        end)
      end
    end,
  })
end

-- Enhanced completion with caching
function M.complete_with_cache()
  local mistral = require("mistral-codestral")

  -- Get context
  local prefix, suffix = mistral.get_fim_context()
  local cache_key = generate_cache_key(prefix, suffix)

  -- Check cache first
  local cached_completion = get_from_cache(cache_key)
  if cached_completion then
    mistral.insert_completion(cached_completion)
    vim.notify("Used cached completion", vim.log.levels.INFO)
    return
  end

  -- Show progress if enabled
  local progress_msg = nil
  if advanced_config.show_progress then
    progress_msg = "⏳ Requesting Codestral completion..."
    vim.notify(progress_msg, vim.log.levels.INFO)
  end

  mistral.request_completion(function(completion)
    if progress_msg then
      -- Clear progress message
      vim.cmd("echon ''")
    end

    if completion then
      add_to_cache(cache_key, completion)
      mistral.insert_completion(completion)
      vim.notify("✓ Codestral completion inserted", vim.log.levels.INFO)
    end
  end)
end

-- Multi-line completion with preview
function M.complete_with_preview()
  local mistral = require("mistral-codestral")

  mistral.request_completion(function(completion)
    if not completion or completion == "" then
      return
    end

    -- Create a floating window to preview completion
    local lines = vim.split(completion, "\n")
    local width = math.max(50, math.min(80, math.max(unpack(vim.tbl_map(string.len, lines)))))
    local height = math.min(10, #lines)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "filetype", vim.bo.filetype)

    local win = vim.api.nvim_open_win(buf, false, {
      relative = "cursor",
      width = width,
      height = height,
      row = 1,
      col = 0,
      style = "minimal",
      border = "rounded",
      title = " Codestral Preview ",
      title_pos = "center",
    })

    -- Set up keybindings for the preview
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set("n", "<CR>", function()
      vim.api.nvim_win_close(win, true)
      mistral.insert_completion(completion)
    end, opts)

    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(win, true)
    end, opts)

    vim.keymap.set("n", "<Esc>", function()
      vim.api.nvim_win_close(win, true)
    end, opts)

    vim.notify("Preview: Press <Enter> to accept, q/<Esc> to cancel", vim.log.levels.INFO)
  end)
end

-- Setup advanced features
function M.setup(user_config)
  advanced_config = vim.tbl_deep_extend("force", advanced_config, user_config or {})

  if advanced_config.enable_auto_completion then
    setup_auto_completion()
  end

  -- Additional commands
  vim.api.nvim_create_user_command("CodestralCompletePreview", M.complete_with_preview, {
    desc = "Get code completion with preview from Mistral Codestral",
  })

  vim.api.nvim_create_user_command("CodestralClearCache", function()
    completion_cache = {}
    cache_order = {}
    vim.notify("Codestral cache cleared", vim.log.levels.INFO)
  end, {
    desc = "Clear Mistral Codestral completion cache",
  })
end

return M
