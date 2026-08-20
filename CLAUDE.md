# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for macOS and Linux, deployed with **GNU Stow**. There is no build, no
test suite, no CI. "Correctness" means: the symlink lands where the tool expects it, and the
config it points at is valid for that tool.

Read `README.md` for the per-platform install/stow package lists, and `nvim/.config/nvim/README.md`
for Neovim-specific setup (LSP, DAP, per-machine config).

## Stow layout (the core convention)

Each top-level directory is a **stow package** whose internal tree mirrors `$HOME`:

- `zsh/.zshrc` → `~/.zshrc`
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `scripts/.local/bin/tm` → `~/.local/bin/tm`

Consequences when editing:

- **Adding a file means placing it at its real `$HOME`-relative path inside the package.**
  A new `~/.config/foo/bar.toml` goes to `foo/.config/foo/bar.toml`, not `foo/bar.toml`.
- The repo is **not** in `$HOME`, so stow always needs an explicit target:
  `stow -t $HOME <package>`.
- `.stow-local-ignore` keeps root-level scripts, `README*`, `pictures/`, and `fonts/` out of
  stow's link set. Non-`$HOME`-shaped payloads live outside the mirrored tree by design
  (`kanata/system/`, `x11/xps/`, `fonts/nerdfonts/`, `pictures/wallpaper/`) and are installed manually.
- `git/` is the exception to pure mirroring: `.gitconfig` sits at the package root and
  `delta.gitconfig` is pulled in via `[include]`, so both must be linked/available together.

## Commands

```bash
# deploy / re-deploy a package (always -t $HOME)
stow -t $HOME zsh nvim tmux git

# preview without writing symlinks
stow -n -v -t $HOME <package>

# remove a package's symlinks
stow -D -t $HOME <package>

# macOS bootstrap: homebrew + brew.txt + brew-cask.txt, then stows nvim
./install_mac.sh

# Linux bootstrap
./install_arch.sh
./install_ubuntu.sh                  # or a single step: ./install_ubuntu.sh <fn-name>

# legacy manual-symlink alternative to stow (Linux-oriented, also installs zsh plugins)
./configure.sh                       # all steps, prompts and DELETES existing ~/.config/nvim
./configure.sh zsh                   # single step -> calls install_zsh
```

`configure.sh` and `stow` are two competing deployment paths over the same files. `configure.sh`
`rm -rf`s targets before linking, and its `install_neovim` links the package root (`nvim/`) rather
than `nvim/.config/nvim/`, so it disagrees with the stow layout. Prefer `stow`; treat `configure.sh`
as legacy unless the user asks for it.

### Validating a change

There is no lint/test harness, so verify per tool:

```bash
# Lua (nvim) — stylua config at nvim/.config/nvim/stylua.toml (2 spaces, 120 cols)
stylua --check nvim/.config/nvim

# shell scripts
shellcheck configure.sh install_*.sh scripts/.local/bin/*

# json / toml configs
jq . karabiner/.config/karabiner/karabiner.json >/dev/null

# nvim plugin changes
nvim --headless "+Lazy! sync" +qa
```

## Per-machine and per-context escape hatches

Never hardcode machine-specific values (paths, hostnames, monitor names, work identities) into
tracked files. Every layer already has a seam:

- `~/.zshenv.local`, `~/.zshrc.local` — sourced if present, untracked (`zsh/.zshenv`, `zsh/.zshrc`)
- `nvim/.config/nvim/lua/config/machine.lua` — gitignored; per-machine plugin enable/disable table,
  seeded from `machine.lua.example`
- `git/.gitconfig` uses `includeIf gitdir:` to load `.gitconfig-work` (`~/workspace/`) and
  `.gitconfig-perso` (`~/personal/`) — both untracked, so identities stay out of the repo
- `claude/.claude/.gitignore` excludes `settings.local.json` and `skills/`

## Notable packages

- **`nvim/`** — LazyVim-based. `lua/config/` is the framework layer (options, keymaps, autocmds,
  lazy bootstrap, machine overrides); `lua/plugins/*.lua` is one spec file per concern
  (`lsp`, `ai`, `git`, `neotest`, `disabled`, …); `lua/ansible/` is a self-contained local module
  (vault, file picker, keymaps, commands) with its own README. `lazy-lock.json` is a tracked
  lockfile: plugin-version bumps are a real, reviewable diff.
- **`zsh/`** — primary shell. antidote in static-load mode (`.zsh_plugins.txt` regenerates
  `~/.zsh_plugins.zsh`), starship prompt, heavy plugins deferred via `kind:defer`. See `zsh/README.md`.
- **`claude/`** — this repository is where Claude Code's own user-level config lives. `claude/.claude/CLAUDE.md`
  stows to `~/.claude/CLAUDE.md` (the global instructions) and delegates coding/testing/git/security/docs
  rules to `claude/.claude/rules/*.md`. Editing these files changes future Claude Code sessions' behavior
  on **every** project, so treat them as higher-blast-radius than any other package here.
- **`kanata/`** — cross-platform remapper; `.config/kanata/` is stowable, `system/` holds a systemd
  unit that is installed by hand (see `kanata/README.md`).

## Platform split

Stow packages are not all portable. Before suggesting one, check it matches the target OS:

- macOS only: `aerospace`, `karabiner`, `sketchybar`
- Linux only: `i3`, `sway`, `polybar`, `waybar`, `rofi`, `gtk-3.0`, `x`, `x11`, `pictures`
- Cross-platform: `zsh`, `git`, `nvim`, `tmux`, `starship`, `alacritty`, `ghostty`, `mise`,
  `scripts`, `kanata`, `fish`, `bash`, `zellij`, `fonts`, `claude`, `lazygit`, `opencode`

macOS-specific gotchas are collected in `mac.md` (AZERTY/Keychron input-source workarounds), and
`fix_macos.sh` re-signs Neovim native libraries (`.so`/`.dylib`) after plugin installs — required
after any `Lazy sync` that builds native code.
