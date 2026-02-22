#!/bin/zsh

# Environment variables. Sourced for every shell (interactive, non-interactive, scripts).

# common
export LANG=fr_FR.UTF-8
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="ghostty"
export BROWSER="chrome"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.luarocks/bin:$PATH"


# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"


# personal
export DOTFILES_DIR="$HOME/personal/dotfiles/"
export PROJECTS_DIR="$HOME/projects/"
export WORK_DIR="$HOME/workspace/"
export PERSO_DIR="$HOME/personal/"
# export DATA_DIR=/data/


# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# local env
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
