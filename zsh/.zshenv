#!/bin/zsh

# Environment variables. Sourced for every shell (interactive, non-interactive, scripts).

# common
export LANG=fr_FR.UTF-8
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="ghostty"
export BROWSER="open" # macOS: opens default browser
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.luarocks/bin:$PATH"
# Dedupe across nested shells and later prepends (brew shellenv exports FPATH,
# so child shells inherit plugin dirs that .zshrc re-adds).
# -U must be on the scalars too: assignments via PATH= bypass the array's flag.
typeset -U path PATH fpath FPATH


# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"


# personal
export DOTFILES_DIR="$HOME/personal/dotfiles/"
export PROJECTS_DIR="$HOME/projects/"
export WORK_DIR="$HOME/workspace/"
export PERSO_DIR="$HOME/personal/"
# export DATA_DIR=/data/



# local env
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
