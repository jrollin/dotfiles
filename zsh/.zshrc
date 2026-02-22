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

setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

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


[[ -f "$HOME/aliasrc" ]] && source "$HOME/aliasrc"

[[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] && source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

command -v rbenv &>/dev/null && eval "$(rbenv init -)"

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

command -v starship &>/dev/null && eval "$(starship init zsh)"

[[ -f "$WORK_DIR/devops/skello.plugin.zsh" ]] && source "$WORK_DIR/devops/skello.plugin.zsh"

[[ -x "$HOME/.local/bin/mise" ]] && eval "$(~/.local/bin/mise activate zsh)"

export GPG_TTY=$(tty)

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
