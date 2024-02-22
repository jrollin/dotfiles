# custom env 
if [ -f "$HOME/.bashrc_env" ]; then
    . "$HOME/.bashrc_env"
fi

# custom PATH 
if [ -f "$HOME/.bashrc_path" ]; then
    . "$HOME/.bashrc_path"
fi

# auto completion
if [ -f /etc/bash.bashrc ]; then
  . /etc/bash.bashrc
fi

# custom aliases
if [ -f "$HOME/.bashrc_alias" ]; then
    . "$HOME/.bashrc_alias"
fi

#ssh agent
if [ -f "$HOME/.bashrc_ssh" ]; then
    . "$HOME/.bashrc_ssh"
fi
