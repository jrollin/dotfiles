# Enable colors
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

# Better directory navigation
setopt AUTO_CD                   # type a directory name to cd into it
setopt AUTO_PUSHD                # cd pushes the old dir onto the stack
setopt PUSHD_IGNORE_DUPS         # no duplicate stack entries
setopt PUSHD_SILENT              # don't print the stack on cd

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored ls
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Android SDK
if [ -d "$HOME/android-sdk" ]; then
    export ANDROID_HOME="$HOME/android-sdk"
    if [ -d "$ANDROID_HOME/platform-tools" ]; then
        export PATH="$PATH:$ANDROID_HOME/platform-tools"
    fi
fi

# Lazy-load mise: activate on first use to keep startup fast
if [[ -x "$HOME/.local/bin/mise" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    mise() {
        unfunction mise
        eval "$(~/.local/bin/mise activate zsh)"
        mise "$@"
    }
fi

export GPG_TTY=$(tty)

# compinit must run BEFORE antidote loads plugins (plugins call `compdef`).
# Run once per day; use cached dump otherwise.
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Plugin manager (antidote) — static-load mode for fast startup.
# antidote bundles ~/.zsh_plugins.txt → ~/.zsh_plugins.zsh once; we just source the result.
ANTIDOTE_HOME="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote"
ANTIDOTE_PLUGINS_TXT="$HOME/.zsh_plugins.txt"
ANTIDOTE_PLUGINS_ZSH="$HOME/.zsh_plugins.zsh"

if [[ -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
    if [[ ! "$ANTIDOTE_PLUGINS_ZSH" -nt "$ANTIDOTE_PLUGINS_TXT" ]]; then
        source "$ANTIDOTE_HOME/antidote.zsh"
        antidote bundle <"$ANTIDOTE_PLUGINS_TXT" >|"$ANTIDOTE_PLUGINS_ZSH"
    fi
    source "$ANTIDOTE_PLUGINS_ZSH"
fi

# Aliases
[[ -f "$HOME/aliasrc" ]] && source "$HOME/aliasrc"

# Custom local overrides (per-machine)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

alias claude-mem='/Users/julienrollin/.bun/bin/bun "/Users/julienrollin/.claude/plugins/cache/thedotmack/claude-mem/10.6.2/scripts/worker-service.cjs"'

# sonarqube-cli
export PATH="$HOME/.local/share/sonarqube-cli/bin:$PATH"
