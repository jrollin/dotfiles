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
