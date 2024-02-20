# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# custom env 
if [ -f "$HOME/.bashrc_env" ]; then
    . "$HOME/.bashrc_env"
fi

# custom PATH 
if [ -f "$HOME/.bashrc_path" ]; then
    . "$HOME/.bashrc_path"
fi

# custom aliases
if [ -f "$HOME/.bashrc_alias" ]; then
    . "$HOME/.bashrc_alias"
fi
