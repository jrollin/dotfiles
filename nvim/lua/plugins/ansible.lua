-- lua/plugins/ansible.lua
return {
  dir = vim.fn.stdpath("config") .. "/lua/plugins/ansible", -- Local plugin path
  name = "ansible-cmd",
  lazy = true,
  keys = {
    { "<leader>aie", mode = "v", desc = "Ansible Vault encrypt selection with vault file" },
    { "<leader>aiv", mode = "v", desc = "Ansible Vault view selection with vault file" },
    { "<leader>afe", desc = "Ansible Vault encrypt file with vault file" },
    { "<leader>afv", desc = "Ansible Vault view file with vault file" },
  },
  config = function()
    -- Create the module
    local ansible = {}

    -- Function to get visual selection
    local function get_visual_selection()
      -- Récupérer les positions de début et fin de la sélection
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")

      local start_line, start_col = start_pos[2], start_pos[3]
      local end_line, end_col = end_pos[2], end_pos[3]

      -- Récupérer les lignes sélectionnées
      local lines = vim.fn.getline(start_line, end_line)

      -- Si le mode visuel est 'v', ajuster le texte pour la sélection partielle
      local mode = vim.fn.visualmode()
      if mode == "v" then
        if start_line == end_line then
          lines[1] = string.sub(lines[1], start_col, end_col)
        else
          lines[1] = string.sub(lines[1], start_col)
          lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end
      elseif mode == "V" then
      -- En mode ligne, pas besoin d'ajustements
      elseif mode == "\22" then -- Mode bloc (Ctrl+v)
        -- En mode bloc, l'implémentation est plus complexe
        local width = end_col - start_col + 1
        for i = 1, #lines do
          lines[i] = string.sub(lines[i], start_col, start_col + width - 1)
        end
      end

      -- Afficher des informations de débogage
      vim.api.nvim_echo({ { "Start: " .. start_line .. "," .. start_col, "Normal" } }, false, {})
      vim.api.nvim_echo({ { "End: " .. end_line .. "," .. end_col, "Normal" } }, false, {})
      vim.api.nvim_echo({ { "Mode: " .. mode, "Normal" } }, false, {})

      return table.concat(lines, "\n")
    end

    function ansible.execute_inline_with_file_picker_vault(cmd_prefix, selection)
      ansible.select_file(cmd_prefix, "Vault file", function(picked)
        -- Build full command
        local escaped_content = string.gsub(selection, "'", "'\\''")
        local full_cmd = string.format(
          "sh -c 'echo \\'%s\\' | tr -d \" \" | ansible-vault decrypt --vault-password-file %s && echo'",
          escaped_content,
          picked.value
        )
        -- Execute the command
        ansible.execute_command(full_cmd)
      end)
    end

    -- Execute command with file picker (works with both Telescope and fallback)
    function ansible.execute_with_file_picker_vault(cmd_prefix, title)
      ansible.select_file(cmd_prefix, title, function(selection)
        local selected_file = selection.value
        ansible.select_file(cmd_prefix, "Vault file", function(picked)
          -- Build full command
          local full_cmd = cmd_prefix .. " " .. selected_file .. "  --vault-password-file " .. picked.value
          -- Execute the command
          ansible.execute_command(full_cmd)
        end)
      end)
    end

    function ansible.select_file(cmd_prefix, title, callback)
      -- Check if telescope is available
      local has_telescope, telescope = pcall(require, "telescope.builtin")
      if has_telescope then
        -- file
        telescope.find_files({
          prompt_title = title .. " " .. cmd_prefix,
          attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
              local selection = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
              require("telescope.actions").close(prompt_bufnr)
              callback(selection)
              return true
            end)
            return true
          end,
          hidden = true,
          no_ignore = true,
        })
      end
    end

    -- Execute the command and show output in new buffer
    function ansible.execute_command(cmd)
      -- Create a new buffer
      local buf = vim.api.nvim_create_buf(false, true)

      -- Set initial message
      -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Executing: " .. cmd, "", "Please wait..." })
      vim.api.nvim_buf_set_option(buf, "modifiable", true)
      vim.api.nvim_buf_set_option(buf, "filetype", "AnsibleOutput")

      -- Open buffer in a new window
      vim.cmd("vsplit")
      vim.api.nvim_win_set_buf(0, buf)

      -- Execute command and capture output
      vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
          -- Check if data exists and is a table
          if data then
            local filtered_data = {}
            if type(data) == "table" then
              -- Filter out empty strings if needed
              for _, line in ipairs(data) do
                if line and line ~= "" then
                  table.insert(filtered_data, line)
                end
              end
            else
              table.insert(filtered_data, data)
            end

            if #filtered_data > 0 then
              vim.api.nvim_buf_set_option(buf, "modifiable", true)
              vim.api.nvim_buf_set_lines(buf, 0, 2, false, { "✓ Completed: " })
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, filtered_data)
              vim.api.nvim_buf_set_option(buf, "modifiable", false)
            end
          end
        end,
        on_stderr = function(_, data)
          -- Similar filtering for stderr
          if data then
            local filtered_data = {}
            if type(data) == "table" then
              -- Filter out empty strings if needed
              for _, line in ipairs(data) do
                if line and line ~= "" then
                  table.insert(filtered_data, line)
                end
              end
            else
              table.insert(filtered_data, data)
            end

            if #filtered_data > 0 then
              vim.api.nvim_buf_set_option(buf, "modifiable", true)
              vim.api.nvim_buf_set_lines(buf, 0, 2, false, { "✗ Failed to decrypt" })
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, filtered_data)
              vim.api.nvim_buf_set_option(buf, "modifiable", false)
            end
          end
        end,
        on_exit = function(_, code)
          vim.api.nvim_buf_set_option(buf, "modifiable", true)
          if code == 0 then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "✓ Command completed successfully", "" })
          else
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "✗ Command failed with code " .. code, "" })
          end
          -- Add the executed command at the end of the buffer for reference
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
        end,
      })
    end

    function trim(s)
      return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
    end

    -- inline
    vim.keymap.set("v", "<leader>aie", function()
      -- Important: Quittez d'abord le mode visuel
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      -- Attendez un peu
      vim.defer_fn(function()
        local selection = get_visual_selection()
        ansible.execute_inline_with_file_picker_vault("ansible-vault encrypt_string", selection)
      end, 100)
    end, { desc = "Ansible vault encrypt selection with vault file" })

    vim.keymap.set("v", "<leader>aiv", function()
      -- Important: Quittez d'abord le mode visuel
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      -- Attendez un peu
      vim.defer_fn(function()
        local selection = trim(get_visual_selection())
        ansible.execute_inline_with_file_picker_vault("ansible-vault view", selection)
      end, 100)
    end, { desc = "Ansible vault decrypt selection with vault file" })

    -- files
    vim.keymap.set("n", "<leader>avf", function()
      ansible.execute_with_file_picker_vault("ansible-vault view", "File to view")
    end, { desc = "Ansible Vault view with vault file " })

    vim.keymap.set("n", "<leader>aef", function()
      ansible.execute_with_file_picker_vault("ansible-vault encrypt", "File to encrypt")
    end, { desc = "Ansible Vault decrypt with vault file " })

    -- comand
    vim.api.nvim_create_user_command("ansile", function()
      print("hello")
    end, {})

    -- Make the module globally available
    package.loaded.ansible = ansible
    _G.ansible = ansible

    return ansible
  end,
}
