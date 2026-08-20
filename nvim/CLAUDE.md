# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Repo-wide conventions (stow layout, platform split, per-machine escape hatches) live in
`../CLAUDE.md`. This file covers only the Neovim package. User-facing setup (Ruby LSP, DAP
adapters, digraphs) is in `.config/nvim/README.md`; the local ansible module documents itself in
`.config/nvim/lua/ansible/README.md`.

## Everything real lives under `.config/nvim/`

`nvim/` is a stow package: the config root is `nvim/.config/nvim/`, which links to
`~/.config/nvim/`. A new file goes at its `$HOME`-relative path inside the package, never at the
package root.

## Architecture: LazyVim + override specs

`init.lua` does one thing: `require("config.lazy")`. From there:

- **`lua/config/lazy.lua`** — bootstraps lazy.nvim, then imports `lazyvim.plugins` followed by
  `plugins`. Import order is the whole override mechanism: LazyVim's specs land first, everything
  in `lua/plugins/*.lua` merges on top. `defaults.lazy = false`, so **custom plugins load at
  startup unless their spec says otherwise** — reach for `event`/`keys`/`cmd`/`lazy = true`
  explicitly.
- **`lazyvim.json`** — the enabled LazyVim extras list, managed by `:LazyExtras`, not by hand.
  Most language support (LSP, treesitter, formatters, linters) comes from an extra here, so check
  this file before adding a plugin: the answer is often "enable the extra instead".
- **`lua/config/{options,keymaps,autocmds}.lua`** — LazyVim loads these automatically (options
  before lazy startup, keymaps/autocmds on `VeryLazy`). Do not `require` them anywhere.
- **`lua/plugins/*.lua`** — one file per concern, each returning a spec or list of specs. Filenames
  are topical (`lsp`, `ai`, `git`, `markdown`, `search`), not plugin-named; a spec goes in the file
  matching its concern.

### Three ways a spec overrides LazyVim

Match the existing idiom rather than inventing a fourth:

1. **Merge a table** — repeat the plugin name with a partial `opts`; lazy.nvim deep-merges
   (`blink.lua`, `neotree.lua`, `colorscheme.lua`).
2. **`opts` as a function** — when the override must *read or filter* what LazyVim already set.
   `lsp.lua` strips `erb-lint`/`erb-formatter` out of `mason.ensure_installed` this way;
   `search.lua` and `disabled.lua` do the same. A table would clobber, a function mutates.
3. **`enabled = false`** — turn a LazyVim-supplied plugin off. Collected in `plugins/disabled.lua`
   with a comment saying what replaced it; `markdown.lua` disables `markdown-preview.nvim` next to
   the replacement so the reason stays adjacent to the fix.

### Per-machine gating

`lua/config/machine.lua` is gitignored, seeded from `machine.lua.example`, and returns a
`{ ["author/plugin"] = bool }` table. A gated spec must load it defensively, because the file is
absent on a fresh clone:

```lua
local ok, machine = pcall(require, "config.machine")
if not ok then machine = {} end
-- enabled = machine["author/plugin"] == true   (opt-in)
```

See `plugins/mistral.lua`. Note the `== true`: absent means disabled.

### Two other conditional-loading patterns already in use

- **Binary probe at spec level** — `lsp.lua` resolves `vim.fn.exepath("ruby-lsp")` once and sets
  `enabled` from it, so a machine without the binary silently skips the server instead of erroring.
  Paired with `mason = false` when the system binary is deliberately preferred over a Mason copy.
- **`cond` on the spec** — `plugins/ansible.lua` gates the whole plugin on
  `vim.fn.executable("ansible-vault")`.

Both exist because this config is deployed to machines with different toolchains. New
external-tool integrations should degrade the same way, never hard-fail at startup.

## `lua/ansible/` — a local plugin, not config

A self-contained Neovim plugin living inside the config, loaded by `plugins/ansible.lua` via
`dir = vim.fn.stdpath("config") .. "/lua/ansible"`. Editing it is plugin work, not config work:
it has a public API (`require("ansible")`), its own `config.lua` defaults + `validate()`, and
modules split by concern (`vault` = command execution, `ui` = buffers/visual selection,
`file_picker` = fzf-lua with a `vim.ui.input` fallback, `keymaps`, `commands`, `utils`).

Constraints worth knowing before touching it:

- Vault commands shell out through `vim.fn.jobstart()`; every interpolated path or payload goes
  through `vim.fn.shellescape()`. Keep that invariant.
- Content is piped via `printf '%s'` rather than passed as an argument, to survive quoting.
  `decrypt_inline` additionally pipes through `tr -d ' '` to strip the YAML indentation of
  `!vault |` blocks — safe only because ciphertext contains no spaces. Encryption must **not**
  strip spaces: plaintext may legitimately contain them.
- Visual-mode entry points defer by `ui.defer_visual_ms` (100ms) after `<Esc>` so the `'<`/`'>`
  marks stabilize before the selection is read.
- The module is Lua-idiomatic but predates the repo's stylua config in places (single quotes).
  Match the file you are editing.

## Validating a change

There is no test suite. Formatting is the only mechanical check:

```bash
stylua --check .config/nvim              # 2 spaces, 120 cols (.config/nvim/stylua.toml)
nvim --headless "+Lazy! sync" +qa        # resolve/install specs, surface spec errors
nvim --headless "+checkhealth" +qa
```

`stylua` is not installed by default on every machine; Mason can provide it. On macOS, any `Lazy
sync` that builds native code must be followed by `../fix_macos.sh`, which `codesign`s every
`.so`/`.dylib` under `~/.local/share/nvim` (it touches the installed plugins, not the repo).

`lazy-lock.json` is tracked: plugin-version bumps are a real, reviewable diff, and
`:Lazy restore` is what pins a new machine to the committed versions. Do not hand-edit it.
