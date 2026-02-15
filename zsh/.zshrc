ZSH_THEME="robbyrussell" # set by `omz`

plugins=(git  colorize zsh-autosuggestions zsh-syntax-highlighting docker npm ansible terraform aws tmux rust encode64 kubectl gh) 

# Enable colors:
autoload -U colors && colors

### Configure color-scheme
COLOR_SCHEME=dark # dark/light

### History Settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/.zsh_history

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

setopt EXTENDED_HISTORY          # Écrire l'horodatage dans l'historique
setopt INC_APPEND_HISTORY        # Ajouter immédiatement à l'historique
setopt SHARE_HISTORY             # Partager l'historique entre les sessions

# Meilleure navigation dans les répertoires
setopt AUTO_CD                   # Taper le nom du répertoire pour cd
setopt AUTO_PUSHD                # Faire que cd pousse l'ancien répertoire sur la pile
setopt PUSHD_IGNORE_DUPS         # Ne pas pousser les doublons
setopt PUSHD_SILENT              # Ne pas afficher la pile de répertoires

# Activer l'autocomplétion
autoload -Uz compinit
compinit

# Complétion insensible à la casse
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Sortie ls colorée
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced


# Android SDK
if [ -d "$HOME/android-sdk" ]; then
    export ANDROID_HOME="$HOME/android-sdk"
    
    if [ -d "$ANDROID_HOME/platform-tools" ]; then
        export PATH="$PATH:$ANDROID_HOME/platform-tools"
    fi
fi


source "$HOME/aliasrc"

source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

# starship
eval "$(starship init zsh)"

