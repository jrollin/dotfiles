-- lua/mistral-codestral/virtual_text.lua
-- Virtual text implementation similar to Windsurf

local M = {}

local namespace = vim.api.nvim_create_namespace("mistral_codestral_virtual_text")
local timer = nil
local current_completions = {}
local current_index = 0
local config = {}

-- Cache mistral module reference for performance
local mistral_module = nil

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

-- Validate and match prefix to avoid showing duplicate text
local function validate_completion_prefix(completion_line, current_line, cursor_col)
  if not completion_line or completion_line == "" then
    return ""
  end
  
  -- Extract the part of current line before and after cursor
  local line_before_cursor = current_line:sub(1, cursor_col)
  local line_after_cursor = current_line:sub(cursor_col + 1)
  
  -- Check if completion would duplicate existing text after cursor
  if line_after_cursor and #line_after_cursor > 0 then
    -- If completion starts with text that already exists after cursor, remove that overlap
    local overlap_length = 0
    local max_check = math.min(#completion_line, #line_after_cursor)
    
    for i = 1, max_check do
      if completion_line:sub(i, i) == line_after_cursor:sub(i, i) then
        overlap_length = i
      else
        break
      end
    end
    
    -- If there's an overlap, skip that part of the completion
    if overlap_length > 0 then
      completion_line = completion_line:sub(overlap_length + 1)
    end
  end
  
  -- Check if completion matches what's already typed (prefix matching)
  local matching_prefix = 0
  local max_prefix_check = math.min(#completion_line, #line_before_cursor)
  
  -- Look for matching suffix in line_before_cursor with prefix in completion_line
  for len = 1, max_prefix_check do
    local line_suffix = line_before_cursor:sub(-len)
    local completion_prefix = completion_line:sub(1, len)
    
    if line_suffix == completion_prefix then
      matching_prefix = len
    end
  end
  
  -- Return the completion text after removing matched prefix
  if matching_prefix > 0 then
    return completion_line:sub(matching_prefix + 1)
  end
  
  -- Return the full completion (after overlap removal)
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
    
    -- Position virtual text without affecting cursor or overriding existing text
    local extmark_opts = {
      virt_text = virt_text,
      virt_text_pos = "eol", -- Always position at end of line
      priority = config.virtual_text.priority or 100,
      hl_mode = "combine",
    }

    -- For the first line, we want to place the extmark at the cursor position
    -- but display the virtual text at end of line to avoid cursor movement
    local extmark_col = (i == 1) and cursor_col or 0
    
    pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, row, extmark_col, extmark_opts)
    
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

  -- Use cached module reference
  if not mistral_module then
    mistral_module = require("mistral-codestral")
  end
  
  local context = mistral_module.get_fim_context_enhanced()

  mistral_module.request_completion(function(completion)
    if completion and completion ~= "" then
      -- For now, we just use one completion, but this could be extended
      -- to request multiple completions for cycling
      current_completions = { completion }
      current_index = 1

      -- Update status while preserving buffer tracking fields
      status.state = "completions"
      status.current = 1
      status.total = #current_completions

      local cursor = vim.api.nvim_win_get_cursor(0)
      show_virtual_text(completion, cursor[1] - 1, cursor[2])
    else
      -- Reset status completely when no completion
      status = {
        state = "idle",
        current = 0,
        total = 0,
        completion_row = nil,
        completion_col = nil,
        completion_bufnr = nil
      }
      current_completions = {}
      current_index = 0
    end

    M.refresh_statusbar()
  end, context)
end

-- Debounced completion request
function M.debounced_complete()
  if timer then
    pcall(vim.fn.timer_stop, timer)
  end

  timer = vim.fn.timer_start(config.virtual_text.idle_delay, function()
    request_virtual_completions()
  end)
end

-- Immediate completion request
function M.complete()
  if timer then
    pcall(vim.fn.timer_stop, timer)
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

    -- Validate we're still in the same buffer where completion was generated
    local bufnr = vim.api.nvim_get_current_buf()
    if status.completion_bufnr and bufnr ~= status.completion_bufnr then
      -- Buffer changed, clear stale completion
      clear_virtual_text()
      return
    end

    -- Apply the same prefix matching logic that was used for display
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]
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
      if not mistral_module then
        mistral_module = require("mistral-codestral")
      end
      mistral_module.insert_completion(completion)
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

    -- Validate we're still in the same buffer where completion was generated
    local bufnr = vim.api.nvim_get_current_buf()
    if status.completion_bufnr and bufnr ~= status.completion_bufnr then
      -- Buffer changed, clear stale completion
      clear_virtual_text()
      return
    end

    -- Apply prefix matching first
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]
    local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
    
    local first_line = vim.split(completion, "\n", { plain = true })[1]
    local processed_line = validate_completion_prefix(first_line, current_line, cursor_col)
    
    if processed_line ~= "" then
      local word = processed_line:match("^%S+") or processed_line
      clear_virtual_text()
      if not mistral_module then
        mistral_module = require("mistral-codestral")
      end
      mistral_module.insert_completion(word)
    else
      clear_virtual_text()
    end
  end
end

-- Accept only the next line
function M.accept_line()
  if #current_completions > 0 and current_index > 0 then
    local completion = current_completions[current_index]

    -- Validate we're still in the same buffer where completion was generated
    local bufnr = vim.api.nvim_get_current_buf()
    if status.completion_bufnr and bufnr ~= status.completion_bufnr then
      -- Buffer changed, clear stale completion
      clear_virtual_text()
      return
    end

    -- Apply prefix matching first
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor[1] - 1
    local cursor_col = cursor[2]
    local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
    
    local first_line = vim.split(completion, "\n", { plain = true })[1]
    local processed_line = validate_completion_prefix(first_line, current_line, cursor_col)
    
    clear_virtual_text()
    if processed_line ~= "" then
      if not mistral_module then
        mistral_module = require("mistral-codestral")
      end
      mistral_module.insert_completion(processed_line)
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
        -- Use cached module reference and check if buffer should be excluded
        if not mistral_module then
          mistral_module = require("mistral-codestral")
        end
        
        if mistral_module.is_buffer_excluded() then
          return
        end
        
        -- Legacy filetype checking (kept for backward compatibility)
        local ft = vim.bo.filetype
        local ft_enabled = vt_config.filetypes[ft]
        if ft_enabled == false then
          return
        end
        if ft_enabled == nil and not vt_config.default_filetype_enabled then
          return
        end

        -- Check minimum character requirement
        local min_chars = vt_config.min_chars or 1
        if min_chars > 1 then
          local cursor = vim.api.nvim_win_get_cursor(0)
          local current_line = vim.api.nvim_get_current_line()
          local cursor_col = cursor[2]
          
          -- Get the current word or context before cursor
          local line_before_cursor = current_line:sub(1, cursor_col)
          local current_word = line_before_cursor:match("%S+$") or ""
          
          -- Only trigger if we have enough characters in current context
          if #current_word < min_chars then
            return
          end
        end

        M.debounced_complete()
      end,
    })

    -- Clear on mode changes (except when staying in insert mode)
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = group,
      callback = function()
        if vim.fn.mode() ~= "i" then
          clear_virtual_text()
        end
      end,
    })

    -- Clear on cursor movement if moved significantly from completion position
    vim.api.nvim_create_autocmd("CursorMovedI", {
      group = group,
      callback = function()
        -- Only check if we have an active completion
        if #current_completions == 0 or not status.completion_row then
          return
        end

        local cursor = vim.api.nvim_win_get_cursor(0)
        local cursor_row = cursor[1] - 1
        local cursor_col = cursor[2]

        -- Clear if moved to different line or moved more than 5 characters away
        if cursor_row ~= status.completion_row or
           math.abs(cursor_col - (status.completion_col or 0)) > 5 then
          clear_virtual_text()
        end
      end,
    })

    -- Clear on leaving insert mode
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      callback = clear_virtual_text,
    })

    -- Clear on leaving buffer
    vim.api.nvim_create_autocmd("BufLeave", {
      group = group,
      callback = clear_virtual_text,
    })
  end

  -- Setup key bindings if enabled
  if vt_config.key_bindings and vt_config.key_bindings ~= false then
    local bindings = vt_config.key_bindings

    if bindings.accept then
      vim.keymap.set("i", bindings.accept, function()
        -- Accept mistral completion if available
        if #current_completions > 0 and current_index > 0 then
          M.accept()
        end
        -- No fallback needed since we're not using Tab anymore
      end, {
        desc = "Accept Codestral completion",
        silent = true,
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
