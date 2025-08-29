# common 
set -x LANG fr_FR.UTF-8
set -x EDITOR nvim
set -x VISUAL nvim
set -x TERMINAL alacritty
set -x BROWSER firefox

# XDG 
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_DATA_HOME "$HOME/.local/share"
set -x XDG_CACHE_HOME "$HOME/.cache"

# personal 
set -x DOTFILES_DIR $HOME/dotfiles/
set -x PROJECTS_DIR $HOME/projects/
set -x WORK_DIR $HOME/workspace/

# rust
[ -d $HOME/.cargo ] && set --export CARGO_ROOT "$HOME/.cargo"
# npm
[ -d $HOME/.npm-global ] && set --export NPM_ROOT "$HOME/.npm-global"

# Extend PATH
# cargo
if test -d $HOME/.cargo
    if not contains "$HOME/.cargo" $PATH
        set --prepend PATH $CARGO_ROOT/bin
    end
end
if not contains $HOME/.local/bin $PATH
    set --prepend PATH $HOME/.local/bin
end
# npm
if test -d $HOME/.npm-global
    if not contains "$HOME/.npm-global" $PATH
        set --prepend PATH $NPM_ROOT/bin
    end
end

# Android SDK
if test -d "$HOME/android-sdk"
    set -gx ANDROID_HOME $HOME/android-sdk

    if test -d "$ANDROID_HOME/platform-tools"
        set -gx PATH $PATH $ANDROID_HOME/platform-tools
    end
end

# Java Home
if test -d /usr/lib/jvm/java-17-openjdk
    set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
end

# playwright skip download 
set -gx PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1

# Warnings 
[ ! -d $HOME/.cargo ] && echo "cargo is missing; install by running: curl https://sh.rustup.rs -sSf | sh"

# prompt
starship init fish | source
