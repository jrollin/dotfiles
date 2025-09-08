fish_config theme choose "Dracula Official"

# disable greetings
set -U fish_greeting ""

set --universal FISH_ROOT (dirname (readlink -f (status -f)))

test -f $FISH_ROOT/exports.fish && source $FISH_ROOT/exports.fish
test -f $FISH_ROOT/alias.fish && source $FISH_ROOT/alias.fish

# ssh agent
# if test -z (pgrep ssh-agent | string collect)
#     eval (ssh-agent -c)
#     set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
#     set -Ux SSH_AGENT_PID $SSH_AGENT_PID
# end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# pnpm
set -gx PNPM_HOME "/home/julien/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
#

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# MISE configuration code
if test -d "$XDG_CONFIG_HOME/mise"
    $HOME /.local/bin/mise activate fish | source
end
