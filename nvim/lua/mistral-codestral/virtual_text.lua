-- lua/mistral-codestral/virtual_text.lua
-- Virtual text implementation similar to Windsurf

local M = {}

local namespace = vim.api.nvim_create_namespace("mistral_codestral_virtual_text")
local timer = nil
local current_completions = {}
local current_index = 0
local config = {}

-- Status tracking
local status = {
  state = "idle", -- "idle", "waiting", "completions"
  current = 0,
  total = 0,
  completion_row = nil, -- Track where completion is shown
  completion_col = nil, -- Track cursor column for completion
  completion_bufnr = nil, -- Track buffer for completion
}

-- Clear virtual text
local function clear_virtual_text()
  -- Cancel any pending timer (using vim.fn timer API)
  if timer then
    pcall(vim.fn.timer_stop, timer)
    timer = nil
  end
  
  -- Clear virtual text safely
  local ok, bufnr = pcall(vim.api.nvim_get_current_buf)
  if ok and bufnr then
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, namespace, 0, -1)
  end
  
  -- Reset state
  current_completions = {}
  current_index = 0
  status = { 
    state = "idle", 
    current = 0, 
    total = 0, 
    completion_row = nil, 
    completion_col = nil, 
    completion_bufnr = nil 
  }
  
  -- Safely refresh statusbar
  pcall(M.refresh_statusbar)
end

-- Validate and match prefix like Windsurf does
local function validate_completion_prefix(completion_line, current_line, cursor_col)
  if not completion_line or completion_line == "" then
    return ""
  end
  
  -- Extract the part of current line before cursor
  local line_prefix = current_line:sub(1, cursor_col)
  
  -- Simple case: if completion starts with what's already typed
  local matching_prefix = 0
  local max_check = math.min(#completion_line, #line_prefix)
  
  -- Check if the end of line_prefix matches the start of completion_line
  for i = 1, max_check do
    local completion_char = completion_line:sub(i, i)
    local line_char = line_prefix:sub(cursor_col - max_check + i, cursor_col - max_check + i)
    
    if completion_char == line_char then
      matching_prefix = i
    else
      break
    end
  end
  
  -- Alternative approach: check if completion starts after cursor position
  if matching_prefix == 0 then
    -- Check for suffix matching (completion continues from where we are)
    local start_check = math.max(1, #line_prefix - #completion_line + 1)
    local suffix_part = line_prefix:sub(start_check)
    
    if completion_line:sub(1, #suffix_part) == suffix_part then
      matching_prefix = #suffix_part
    end
  end
  
  -- Return the completion text after removing matched prefix
  if matching_prefix > 0 and matching_prefix <= #completion_line then
    local result = completion_line:sub(matching_prefix + 1)
    return result
  end
  
  -- If no match found, return the full completion
  return completion_line
end

-- Show virtual text completion
local function show_virtual_text(completion, cursor_row, cursor_col)
  if not completion or completion == "" then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.split(completion, "\n", { plain = true })

  -- Validate cursor position
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if cursor_row >= line_count then
    return -- Invalid row, skip showing virtual text
  end

  -- Get current line for validation and prefix matching
  local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1]
  if not current_line then
    return -- Invalid line, skip
  end

  -- Update status tracking
  status.completion_row = cursor_row
  status.completion_col = cursor_col
  status.completion_bufnr = bufnr

  -- Clear previous virtual text
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, cursor_row, cursor_row + #lines + 5)

  for i, line in ipairs(lines) do
    if line == "" then
      goto continue -- Skip empty lines
    end

    local row = cursor_row + i - 1
    -- Ensure row is valid
    if row >= line_count then
      break -- Don't try to show beyond end of buffer
    end

    -- Apply prefix matching for the first line
    local display_text = line
    if i == 1 then
      display_text = validate_completion_prefix(line, current_line, cursor_col)
      if display_text == "" then
        goto continue -- Nothing to show after prefix matching
      end
    end

    local virt_text = {{ display_text, "Comment" }}
    
    -- Use Windsurf-style positioning with virt_text_win_col
    local display_col
    if i == 1 then
      -- First line: calculate virtual column position after cursor
      local virt_col = vim.fn.virtcol({ cursor_row + 1, cursor_col + 1 })
      display_col = virt_col
    else
      -- Subsequent lines: show at beginning of line
      display_col = 1
    end

    -- Always place extmark at column 0, use virt_text_win_col for positioning
    local extmark_opts = {
      virt_text = virt_text,
      virt_text_win_col = display_col - 1, -- 0-indexed
      priority = config.virtual_text.priority,
      hl_mode = "combine",
    }

    pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, row, 0, extmark_opts)
    
    ::continue::
  end
end

-- Request completions for virtual text
local function request_virtual_completions()
  if status.state == "waiting" then
    return -- Already waiting for response
  end

  status.state = "waiting"
  M.refresh_statusbar()

  local mistral = require("mistral-codestral")
  local context = mistral.get_fim_context_enhanced()

  mistral.request_completion(function(completion)
    if completion and completion ~= "" then
      -- For now, we just use one completion, but this could be extended
      -- to request multiple completions for cycling
      current_completions = { completion }
      current_index = 1

      status = {
        state = "completions",
        current = 1,
        total = #current_completions,
      }

      local cursor = vim.api.nvim_win_get_cursor(0)
      show_virtual_text(completion, cursor[1] - 1, cursor[2])
    else
      status = { state = "idle", current = 0, total = 0 }
      current_completions = {}
      current_index = 0
    end

    M.refresh_statusbar()
  end, context)
end

-- Debounced completion request
function M.debounced_complete()
  if timer then
    vim.fn.timer_stop(timer)
  end

  timer = vim.fn.timer_start(config.virtual_text.idle_delay, function()
    request_virtual_completions()
  end)
end

-- Immediate completion request
function M.complete()
  if timer then
    vim.fn.timer_stop(timer)
    timer = nil
  end
  request_virtual_completions()
end

-- Cycle through completions or complete if none available
function M.cycle_or_complete()
  if #current_completions > 0 then
    M.cycle_completions(1)
  else
    M.complete()
  end
end

-- Cycle through completions
function M.cycle_completions(direction)
  if #current_completions == 0 then
    return
  end

  current_index = current_index + direction
  if current_index > #current_completions then
    current_index = 1
  elseif current_index < 1 then
    current_index = #current_completions
  end

  status.current = current_index
  M.refresh_statusbar()

  local cursor = vim.api.nvim_win_get_cursor(0)
  show_virtual_text(current_completions[current_index], cursor[1] - 1, cursor[2])
end

-- Accept current completion
function M.accept()
  if #current_completions > 0 and current_index > 0 then
    local completion = current_completions[current_index]
    
    -- Apply the same prefix matching logic that was used for display
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]
    local bufnr = vim.api.nvim_get_current_buf()
    local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
    
    -- Process completion with prefix matching
    local completion_lines = vim.split(completion, "\n", { plain = true })
    if #completion_lines > 0 then
      -- Apply prefix matching to first line
      local first_line = completion_lines[1]
      local processed_first_line = validate_completion_prefix(first_line, current_line, cursor_col)
      
      -- Rebuild completion with processed first line
      if processed_first_line ~= "" then
        completion_lines[1] = processed_first_line
        completion = table.concat(completion_lines, "\n")
      else
        -- If first line is completely matched, remove it and shift
        table.remove(completion_lines, 1)
        if #completion_lines > 0 then
          completion = table.concat(completion_lines, "\n")
        else
          completion = ""
        end
      end
    end
    
    clear_virtual_text()
    if completion ~= "" then
      require("mistral-codestral").insert_completion(completion)
    end
  elseif config.virtual_text.accept_fallback then
    -- Execute fallback key
    vim.api.nvim_feedkeys(config.virtual_text.accept_fallback, "n", false)
  end
end

-- Accept only the next word
function M.accept_word()
  if #current_completions > 0 and current_index > 0 then
    local completion = current_completions[current_index]
    
    -- Apply prefix matching first
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]
    local bufnr = vim.api.nvim_get_current_buf()
    local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
    
    local first_line = vim.split(completion, "\n", { plain = true })[1]
    local processed_line = validate_completion_prefix(first_line, current_line, cursor_col)
    
    if processed_line ~= "" then
      local word = processed_line:match("^%S+") or processed_line
      clear_virtual_text()
      require("mistral-codestral").insert_completion(word)
    else
      clear_virtual_text()
    end
  end
end

-- Accept only the next line
function M.accept_line()
  if #current_completions > 0 and current_index > 0 then
    local completion = current_completions[current_index]
    
    -- Apply prefix matching first
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]
    local bufnr = vim.api.nvim_get_current_buf()
    local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
    
    local first_line = vim.split(completion, "\n", { plain = true })[1]
    local processed_line = validate_completion_prefix(first_line, current_line, cursor_col)
    
    clear_virtual_text()
    if processed_line ~= "" then
      require("mistral-codestral").insert_completion(processed_line)
    end
  end
end

-- Status functions for statusline integration
function M.status_string()
  if status.state == "idle" then
    return "   "
  elseif status.state == "waiting" then
    return " * "
  elseif status.state == "completions" and status.total > 0 then
    return string.format("%d/%d", status.current, status.total)
  else
    return " 0 "
  end
end

function M.status()
  return vim.deepcopy(status)
end

-- Statusbar refresh function (can be customized)
local statusbar_refresh_fn = function() end

function M.set_statusbar_refresh(fn)
  statusbar_refresh_fn = fn
end

function M.refresh_statusbar()
  statusbar_refresh_fn()
end

-- Setup virtual text functionality
function M.setup(mistral_config)
  config = mistral_config

  local vt_config = config.virtual_text

  -- Auto-completion setup
  if not vt_config.manual then
    local group = vim.api.nvim_create_augroup("MistralCodestralVirtualText", { clear = true })

    -- Trigger on text changes in insert mode
    vim.api.nvim_create_autocmd({ "TextChangedI" }, {
      group = group,
      callback = function()
        local ft = vim.bo.filetype
        local ft_enabled = vt_config.filetypes[ft]
        if ft_enabled == false then
          return
        end
        if ft_enabled == nil and not vt_config.default_filetype_enabled then
          return
        end

        M.debounced_complete()
      end,
    })

    -- Clear on mode changes
    vim.api.nvim_create_autocmd({ "ModeChanged", "CursorMovedI" }, {
      group = group,
      callback = function()
        if vim.fn.mode() ~= "i" then
          clear_virtual_text()
        end
      end,
    })

    -- Clear on leaving insert mode
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      callback = clear_virtual_text,
    })
  end

  -- Setup key bindings if enabled
  if vt_config.key_bindings and vt_config.key_bindings ~= false then
    local bindings = vt_config.key_bindings

    if bindings.accept then
      vim.keymap.set("i", bindings.accept, function()
        if #current_completions > 0 and current_index > 0 then
          M.accept()
          return ""  -- Don't insert anything when completion is accepted
        else
          -- Fallback: check for other completion engines or insert normal tab
          -- This allows blink.cmp or other completion plugins to handle Tab
          local fallback_key = vim.api.nvim_replace_termcodes(bindings.accept, true, false, true)
          
          -- Try to use blink.cmp Tab handling if available
          local blink_ok, blink = pcall(require, "blink.cmp")
          if blink_ok and blink.is_open() then
            return fallback_key  -- Let blink.cmp handle it
          end
          
          -- Default fallback: return the original key for normal indentation
          return fallback_key
        end
      end, {
        desc = "Accept Codestral completion or fallback",
        expr = true,
        replace_keycodes = false,  -- Handle replace_termcodes manually above
        silent = false,
      })
    end

    if bindings.accept_word then
      vim.keymap.set("i", bindings.accept_word, M.accept_word, {
        desc = "Accept Codestral word",
        silent = true,
      })
    end

    if bindings.accept_line then
      vim.keymap.set("i", bindings.accept_line, M.accept_line, {
        desc = "Accept Codestral line",
        silent = true,
      })
    end

    if bindings.next then
      vim.keymap.set("i", bindings.next, function()
        M.cycle_completions(1)
      end, {
        desc = "Next Codestral completion",
        silent = true,
      })
    end

    if bindings.prev then
      vim.keymap.set("i", bindings.prev, function()
        M.cycle_completions(-1)
      end, {
        desc = "Previous Codestral completion",
        silent = true,
      })
    end

    if bindings.clear then
      -- Simple clear binding for insert mode
      vim.keymap.set("i", bindings.clear, clear_virtual_text, {
        desc = "Clear Codestral completion",
        silent = true,
      })
      
      -- Clear binding for normal mode
      vim.keymap.set("n", bindings.clear, clear_virtual_text, {
        desc = "Clear Codestral completion",
        silent = true,
      })
    end
    
    -- Simple autocmd pattern like Windsurf - clear on insert leave and buffer leave
    vim.api.nvim_create_autocmd("InsertLeave", {
      callback = function()
        if #current_completions > 0 then
          clear_virtual_text()
        end
      end,
      desc = "Clear Codestral completion when leaving insert mode",
    })
    
    vim.api.nvim_create_autocmd("BufLeave", {
      callback = function()
        if #current_completions > 0 then
          clear_virtual_text()
        end
      end,
      desc = "Clear Codestral completion when leaving buffer",
    })
    
  end

  -- Create commands for manual mode
  vim.api.nvim_create_user_command("MistralCodestralVirtualComplete", M.complete, {
    desc = "Manually trigger Codestral virtual text completion",
  })

  vim.api.nvim_create_user_command("MistralCodestralVirtualClear", clear_virtual_text, {
    desc = "Clear Codestral virtual text",
  })
end

return M
