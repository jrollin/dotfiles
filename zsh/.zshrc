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


source "$HOME/.config/zsh/aliasrc"

source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

. "$HOME/.asdf/asdf.sh"
#
# starship
eval "$(starship init zsh)"

