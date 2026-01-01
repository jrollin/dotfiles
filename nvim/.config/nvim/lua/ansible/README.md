# Ansible Vault Plugin

A Neovim plugin for encrypting and decrypting Ansible vault strings and files directly from the editor.

## Features

- **Inline Encryption**: Encrypt selected text with `ansible-vault encrypt_string`
- **Inline Decryption**: Decrypt vault strings with `ansible-vault decrypt`
- **File Operations**: Encrypt, decrypt, and view entire files
- **User Commands**: `:AnsibleVaultEncrypt`, `:AnsibleVaultDecrypt`, `:AnsibleVaultView`
- **Telescope Integration**: Beautiful file picker (falls back to vim.ui if unavailable)
- **Clear Prompts**: Descriptive prompts that guide you through each step
- **Configurable**: Customize keymaps, UI, and vault settings
- **Lazy Loading**: Only loads when needed (on keymap or command trigger)
- **Conditional Loading**: Only loads if `ansible-vault` is installed

## Installation

The plugin is already configured in `lua/plugins/ansible.lua`.

### Requirements

- `ansible-vault` command-line tool installed
- (Optional) `telescope.nvim` for better file picker UI

## Usage

### Default Keymaps

| Keymap | Mode | Action |
|--------|------|--------|
| `<leader>aie` | Visual | Encrypt selected text to vault string |
| `<leader>aiv` | Visual | Decrypt vault string to plaintext |
| `<leader>afe` | Normal | Encrypt a file |
| `<leader>afv` | Normal | Decrypt/view an encrypted file |

### Inline Operations (Visual Mode)

#### Encrypt Selection
1. Select text in visual mode
2. Press `<leader>aie`
3. Select a vault password file from the picker
4. Encrypted string appears in a new split window

**Example:**
```yaml
# Before
secret: my-password

# After selecting "my-password" and pressing <leader>aie
secret: !vault |
  $ANSIBLE_VAULT;1.1;AES256;filter_default
  66386d8fa...
  (encrypted content)
```

#### Decrypt Vault String
1. Select an encrypted vault string in visual mode
2. Press `<leader>aiv`
3. Select the vault password file when prompted: "Select Ansible Vault password file"
4. Decrypted plaintext appears in a new split window

### File Operations (Normal Mode)

#### Encrypt File
1. Press `<leader>afe`
2. When prompted "Select file to encrypt", choose the file to encrypt
3. When prompted "Select Ansible Vault password file", choose the vault password file
4. File is encrypted in-place

#### View Encrypted File
1. Press `<leader>afv`
2. When prompted "Select encrypted file to view", choose the encrypted file
3. When prompted "Select Ansible Vault password file", choose the vault password file
4. Decrypted content appears in a new split window

### User Commands

The plugin provides Neovim commands for quick access:

#### Encrypt File
```vim
:AnsibleVaultEncrypt                 " Show file picker
:AnsibleVaultEncrypt path/to/file    " Encrypt specific file
```
- Shows file picker if no argument provided
- If file path given, uses it directly and shows vault file picker

#### Decrypt File
```vim
:AnsibleVaultDecrypt                 " Show file picker
:AnsibleVaultDecrypt path/to/file    " Decrypt specific file
```
- Shows file picker if no argument provided
- If file path given, uses it directly and shows vault file picker

#### View Encrypted File
```vim
:AnsibleVaultView                    " Show file picker
:AnsibleVaultView path/to/file       " View specific file
```
- Shows file picker if no argument provided
- If file path given, uses it directly and shows vault file picker

#### Usage Examples
```vim
" Encrypt a file with picker
:AnsibleVaultEncrypt

" Encrypt specific file
:AnsibleVaultEncrypt secrets.yml

" View encrypted file with picker
:AnsibleVaultView

" View specific encrypted file
:AnsibleVaultView production/secrets.yml

" Decrypt file in current directory
:AnsibleVaultDecrypt config.yml
```

### Prompt Flow

The plugin uses clear, descriptive prompts to guide you through operations:

**Encrypt File Flow:**
```
:AnsibleVaultEncrypt
  ↓
  Picker: "Select file to encrypt"          (Choose file to encrypt)
  ↓
  Picker: "Select Ansible Vault password file"  (Choose vault password file)
  ↓
  ✓ File encrypted
```

**Decrypt File Flow:**
```
:AnsibleVaultDecrypt
  ↓
  Picker: "Select file to decrypt"          (Choose file to decrypt)
  ↓
  Picker: "Select Ansible Vault password file"  (Choose vault password file)
  ↓
  ✓ File decrypted
```

**View Encrypted File Flow:**
```
:AnsibleVaultView
  ↓
  Picker: "Select file to view"             (Choose file to view)
  ↓
  Picker: "Select Ansible Vault password file"  (Choose vault password file)
  ↓
  ✓ Content displayed
```

**Inline Encrypt Selection:**
```
<leader>aie (visual mode)
  ↓
  Picker: "Select Ansible Vault password file"  (Choose vault password file)
  ↓
  ✓ Selection encrypted
```

## Configuration

### Default Configuration

```lua
require('ansible').setup({
  -- Keymap configuration
  keymaps = {
    enabled = true,
    inline_encrypt = '<leader>aie',
    inline_decrypt = '<leader>aiv',
    file_encrypt = '<leader>afe',
    file_decrypt = '<leader>afv',
  },

  -- UI configuration
  ui = {
    split = 'vsplit',              -- 'vsplit', 'split', 'tabnew'
    output_filetype = 'AnsibleOutput',
    show_command = false,
    defer_visual_ms = 100,         -- Delay before processing visual selection
  },

  -- File picker configuration
  file_picker = {
    prefer_telescope = true,       -- Use telescope if available
    fallback_to_vim_ui = true,     -- Fallback to vim.ui.input
    telescope_opts = {
      hidden = true,               -- Show hidden files
      no_ignore = true,            -- Ignore .gitignore
    },
  },

  -- Vault settings
  vault = {
    default_vault_file = nil,      -- Optional default vault file path
    prompt_for_vault_file = true,  -- Always ask for vault file
  },

  -- Command configuration
  commands = {
    enabled = true,                -- Enable :AnsibleVault* commands
  },
})
```

### Custom Configuration Examples

#### Override Keymaps

```lua
-- lua/plugins/ansible.lua
return {
  dir = vim.fn.stdpath('config') .. '/lua/ansible',
  lazy = true,
  keys = {
    { '<leader>ve', mode = 'v', desc = 'Vault encrypt' },
    { '<leader>vd', mode = 'v', desc = 'Vault decrypt' },
    { '<leader>vfe', desc = 'Vault encrypt file' },
    { '<leader>vfd', desc = 'Vault decrypt file' },
  },
  config = function()
    require('ansible').setup({
      keymaps = {
        enabled = true,
        inline_encrypt = '<leader>ve',
        inline_decrypt = '<leader>vd',
        file_encrypt = '<leader>vfe',
        file_decrypt = '<leader>vfd',
      },
    })
  end,
}
```

#### Disable Keymaps (Use Commands Only)

```lua
require('ansible').setup({
  keymaps = {
    enabled = false,  -- Disable all keymaps
  },
})
```

#### Set Default Vault File

```lua
require('ansible').setup({
  vault = {
    default_vault_file = '~/.ansible/vault_pass.txt',
    prompt_for_vault_file = false,  -- Never ask for vault file
  },
})
```

#### Use Horizontal Split Instead

```lua
require('ansible').setup({
  ui = {
    split = 'split',  -- Use horizontal split
  },
})
```

#### Use Tab for Output Display

```lua
require('ansible').setup({
  ui = {
    split = 'tabnew',  -- Open in new tab
  },
})
```

## Output Display

Operations open a split window showing:

### Success
```
✓ Completed:
<encrypted or decrypted content>
```

### Failure
```
✗ Failed (code N):
<error message>
```

The output buffer is read-only and has filetype `AnsibleOutput` for syntax highlighting customization.

## How It Works

### Architecture

The plugin is organized into focused modules:

- **init.lua** - Main orchestrator and public API
- **config.lua** - Default configuration and validation
- **vault.lua** - Ansible vault operations and command execution
- **ui.lua** - Buffer creation and visual selection handling
- **file_picker.lua** - Telescope/vim.ui integration
- **keymaps.lua** - Keymap setup
- **commands.lua** - User command definitions
- **utils.lua** - Helper utilities

### Command Execution

Commands are executed asynchronously using `vim.fn.jobstart()`:

1. Creates a scratch buffer in a split window
2. Shows "Executing command..." message
3. Captures stdout/stderr from the command
4. Displays results with status indicator (✓ or ✗)

### Visual Selection

Visual mode operations use a deferred execution pattern:

1. Exit visual mode (preserve selection marks)
2. Wait 100ms (configurable) for marks to stabilize
3. Extract selection using `getpos("'<")` and `getpos("'>")`
4. Handle different visual modes: character ('v'), line ('V'), block (Ctrl+v)

## Troubleshooting

### Plugin doesn't load
- Verify `ansible-vault` is installed: `which ansible-vault`
- Check Neovim error messages: `:messages`

### File picker doesn't appear
- Install `telescope.nvim` for better UX
- Or configure fallback: `fallback_to_vim_ui = true`

### Encryption/decryption fails
- Ensure vault password file is readable
- Check vault password file format
- Verify `ansible-vault` works from command line

### Wrong split direction
- Configure `ui.split` to `'split'`, `'vsplit'`, or `'tabnew'`

### Keymaps not working
- Verify keymaps are enabled: `keymaps.enabled = true`
- Check for keymap conflicts: `:map <leader>aie`
- Ensure plugin is loaded (trigger with any keymap)

## API

Public functions available via `require('ansible')`:

```lua
require('ansible').setup(config)              -- Initialize plugin
require('ansible').get_config()               -- Get merged config
require('ansible').encrypt_inline()           -- Encrypt visual selection
require('ansible').decrypt_inline()           -- Decrypt visual selection
require('ansible').encrypt_file()             -- Encrypt file
require('ansible').decrypt_file()             -- Decrypt file
require('ansible').view_file()                -- View encrypted file
```

## Performance

- **Lazy Loading**: Plugin only loads when a keymap is triggered
- **Conditional Loading**: Skipped entirely if `ansible-vault` not installed
- **Optional Dependencies**: Telescope is optional, plugin works without it
- **Async Execution**: All vault operations run asynchronously

## Security

- Content is passed safely using `vim.fn.shellescape()`
- Vault password files are expanded and sanitized
- Output buffers are read-only after display
- No secrets stored in Neovim configuration

## License

See the main Neovim configuration license.
