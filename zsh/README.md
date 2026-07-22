# zsh

Zsh configuration managed with GNU Stow. Plugins are handled by
[antidote](https://getantidote.github.io) in static-load mode, prompt by
[starship](https://starship.rs).

## Files

| File | Purpose |
| --- | --- |
| `.zshenv` | Environment variables, sourced by every shell (interactive or not) |
| `.zshrc` | Interactive setup: history, completion, plugins, keybindings, prompt |
| `.zprofile` | Login shells (currently unused placeholder) |
| `.zsh_plugins.txt` | antidote plugin list |
| `aliasrc` | Aliases and helper functions |

## Install

```sh
brew install antidote starship
stow zsh # from the dotfiles root
```

## Plugins

antidote regenerates `~/.zsh_plugins.zsh` automatically whenever
`.zsh_plugins.txt` is newer, then `.zshrc` just sources the static result.
Heavy plugins use `kind:defer` so they load after the first prompt.

## Per-machine overrides

Not tracked, sourced if present:

- `~/.zshenv.local` — extra environment variables
- `~/.zshrc.local` — extra interactive config
