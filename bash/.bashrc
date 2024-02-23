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

#ssh agent
if [ -f "$HOME/.bashrc_ssh" ]; then
    . "$HOME/.bashrc_ssh"
fi

# auto completion
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

# git autocomplete
# curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
