# Startup profiling (opt-in): ZSH_PROFILE=1 zsh -i -c exit
[[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof

# Enable colors
autoload -U colors && colors

### History Settings
# History is state, not cache — keep it out of ~/.cache so cache purges don't wipe it
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt INTERACTIVE_COMMENTS

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

[[ -n $TTY ]] && export GPG_TTY=$TTY

# Search history in a background process — the sync default blocks the keystroke.
# Must be set before antidote loads zsh-autosuggestions, which reads it at load time.
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Plugin manager (antidote) — static-load mode for fast startup.
# antidote bundles ~/.zsh_plugins.txt → ~/.zsh_plugins.zsh once; we just source the result.
ANTIDOTE_HOME="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote"
ANTIDOTE_PLUGINS_TXT="$HOME/.zsh_plugins.txt"
ANTIDOTE_PLUGINS_ZSH="$HOME/.zsh_plugins.zsh"

if [[ -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
    # Rebundle when the plugin list changes OR antidote itself is upgraded: the
    # generated file bakes in versioned Cellar paths that vanish on `brew upgrade`.
    if [[ ! "$ANTIDOTE_PLUGINS_ZSH" -nt "$ANTIDOTE_PLUGINS_TXT" \
       || ! "$ANTIDOTE_PLUGINS_ZSH" -nt "$ANTIDOTE_HOME/antidote.zsh" ]]; then
        source "$ANTIDOTE_HOME/antidote.zsh"
        antidote bundle <"$ANTIDOTE_PLUGINS_TXT" >|"$ANTIDOTE_PLUGINS_ZSH"
    fi
    source "$ANTIDOTE_PLUGINS_ZSH"
fi

# compinit must run AFTER antidote so kind:fpath plugins (zsh-completions) are in
# fpath when the dump is built. No current plugin calls `compdef` at load time.
# Run once per day; use cached dump otherwise.
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
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
