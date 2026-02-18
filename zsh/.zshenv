#!/bin/zsh

# Profile file. Runs on login. Environmental variables are set here.

# common 
export LANG=fr_FR.UTF-8
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="ghostty"
export BROWSER="chrome"
export CARGO_PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/bin:$CARGO_PATH:$PATH


# XDG 
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"


# personal 
export DOTFILES_DIR=$HOME/dotfiles/
export PROJECTS_DIR=$HOME/projects/
export WORK_DIR=$HOME/workspace/
export PERSO_DIR=$HOME/personal/
# export DATA_DIR=/data/


# lua bin (ex: busted for tests)
export PATH="$PATH:$HOME/.luarocks/bin/"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# local env 
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

