ZSH_THEME="dracula"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker asdf npm ansible terraform aws tmux rust encode64 kubectl) 

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



# Android SDK
if [ -d "$HOME/android-sdk" ]; then
    export ANDROID_HOME="$HOME/android-sdk"
    
    if [ -d "$ANDROID_HOME/platform-tools" ]; then
        export PATH="$PATH:$ANDROID_HOME/platform-tools"
    fi
fi

# Java Home
if [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
fi

source "$HOME/.config/zsh/aliasrc"

source "$HOME/.oh-my-zsh/oh-my-zsh.sh"


if [ -f ~/.zshenv.local ]; then
  source ~/.zshhenv.local 
fi

. "$HOME/.asdf/asdf.sh"
# set GO_ROOT env
. ~/.asdf/plugins/golang/set-env.zsh
#
# starship
eval "$(starship init zsh)"


# >>>> Vagrant command completion (start)
fpath=(/opt/vagrant/embedded/gems/gems/vagrant-2.3.7/contrib/zsh $fpath)
compinit
# <<<<  Vagrant command completion (end)

# pnpm
export PNPM_HOME="/home/julien/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
