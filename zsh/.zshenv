
#!/bin/zsh

# Profile file. Runs on login. Environmental variables are set here.

# common 
export LANG=fr_FR.UTF-8
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export PATH=$HOME/.local/bin:$PATH


# XDG 
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"


# personal 
export DOTFILE_DIR=$HOME/dotfiles
export PROJECT_DIR=$HOME/projects/

# lua bin (ex: busted for tests)
export PATH="$PATH:$HOME/.luarocks/bin/"
# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"


