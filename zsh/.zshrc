# Startup profiling (opt-in): ZSH_PROFILE=1 zsh -i -c exit
[[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof

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
setopt INTERACTIVE_COMMENTS
HIST_STAMPS="yyyy-mm-dd"

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

# mise: shims-mode activation, inlined. `mise activate --shims zsh` only emits
# these two static PATH exports, so we skip the ~29ms binary spin-up at startup.
# Auto-switching on `cd` is disabled in this mode (versions resolve when the
# shim is invoked). Keep ordering in sync with `mise activate --shims zsh`.
if [[ -x "$HOME/.local/bin/mise" ]]; then
    export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
fi

if tty &>/dev/null; then export GPG_TTY=$(tty); fi

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

# macOS 26 zsh defaults main keymap to viins — emacs mode gives us ^R history-search,
# ^A/^E line-start/end, and other standard readline bindings.
bindkey -e

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

# sonarqube-cli
export PATH="$HOME/.local/share/sonarqube-cli/bin:$PATH"

# Startup profiling report (opt-in): prints when ZSH_PROFILE is set
[[ -n $ZSH_PROFILE ]] && zprof
