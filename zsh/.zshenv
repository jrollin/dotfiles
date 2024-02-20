
#!/bin/zsh

# Profile file. Runs on login. Environmental variables are set here.

# common 
export LANG=fr_FR.UTF-8
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export CARGO_PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/bin:$CARGO_PATH:PATH


# XDG 
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"


# personal 
export DOTFILES_DIR=$HOME/dotfiles/
export PROJECTS_DIR=$HOME/projects/
export WORK_DIR=$HOME/workspace/
# export DATA_DIR=/data/

# lua bin (ex: busted for tests)
export PATH="$PATH:$HOME/.luarocks/bin/"
# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"


# flutter

export JAVA_HOME='/usr/lib/jvm/java-8-openjdk/jre'
# export JAVA_HOME="/home/julien/.asdf/installs/java/openjdk-16/"
export PATH=$JAVA_HOME/bin:$PATH 

export PATH="$PATH:$HOME/flutter/bin"
 
export ANDROID_HOME="$HOME/Android/"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
# when os package ?
# export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
# export PATH=$PATH:$ANDROID_ROOT/emulator
# export PATH=$PATH:$ANDROID_SDK_ROOT/tools
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/

export ANDROID_STUDIO="$HOME/android-studio"
export PATH=$PATH:$ANDROID_STUDIO/bin/

export PATH=$PATH:$HOME/Downloads/sonar-scanner-5.0.1.3006-linux/bin/

if [ -e /home/julien/.nix-profile/etc/profile.d/nix.sh ]; then . /home/julien/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
