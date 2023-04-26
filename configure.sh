#!/usr/bin/env bash

install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf $XDG_CONFIG_HOME/nvim $HOME/.fzf \
  && ln -s $(pwd)/nvim $XDG_CONFIG_HOME/nvim 
}

install_i3() {
    echo "installing_i3.." \
        && rm -rf $XDG_CONFIG_HOME/i3 \
        && ln -s $(pwd)/i3 $XDG_CONFIG_HOME/i3  
}

install_i3_wallpaper() {
    echo "installing_i3wallper.." \
        && rm -rf $XDG_CONFIG_HOME/pictures \
        && ln -s $(pwd)/pictures $XDG_CONFIG_HOME/pictures  
}

install_i3menu() {
    echo "installing_i3menu.." \
        && rm -rf $XDG_CONFIG_HOME/rofi \
        && ln -s $(pwd)/rofi $XDG_CONFIG_HOME/rofi  
    echo "installing_polybar.." \
        && rm -rf $XDG_CONFIG_HOME/polybar \
        && ln -s $(pwd)/polybar $XDG_CONFIG_HOME/polybar  
}

install_monitor() {
    echo "installing_monitor.." \
        && rm -rf $XDG_CONFIG_HOME/monitor_layout.sh \
        && ln -s $(pwd)/monitor_layout.sh $XDG_CONFIG_HOME/monitor_layout.sh
}

install_tmux() {
    echo "installing tmux tpm" \
        && rm -rf $XDG_CONFIG_HOME/tmux \
        && ln -s $(pwd)/tmux $XDG_CONFIG_HOME/tmux
 }

install_zsh() {
    echo "installing zsh" \
        && rm -f $HOME/.zshrc \
        && ln -s $(pwd)/.zshrc $HOME/.zshrc \
        && mkdir -p "$HOME/.cache/zsh"

    echo "Installing zsh theme..." \
        && rm -rf $XDG_CONFIG_HOME/dracula.zsh-theme \
        && git clone https://github.com/dracula/zsh.git $XDG_CONFIG_HOME/dracula.zsh-theme \
        && rm -f $HOME/.oh-my-zsh/themes/dracula.zsh-theme \
        && ln -s $XDG_CONFIG_HOME/dracula.zsh-theme/dracula.zsh-theme  $HOME/.oh-my-zsh/themes/dracula.zsh-theme
}

install_term() {
    echo "installing term" \
        && rm -rf $XDG_CONFIG_HOME/alacritty \
        && ln -s $(pwd)/alacritty $XDG_CONFIG_HOME/alacritty 

    cargo install alacritty 
    
    echo "installing starship" \
        && rm -rf $XDG_CONFIG_HOME/starship.toml \
        && ln -s $(pwd)/starship.toml $XDG_CONFIG_HOME/starship.toml

    cargo install starship --locked
}

install_ts() {
    echo "Installing ts..." \
        && npm install -g typescript prettier neovim
}

install_asdf(){
    echo "Installing Asdf..." \
    && git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.11.1
    # nodejs
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs latest
    asdf global nodejs latest
}

if [[ -z $1 ]]; then
  echo -n "This will delete all your previous nvim, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    install_neovim \
    && install_i3 \
    && install_i3_wallpaper\
    && install_i3menu \
    && install_monitor \
    && install_tmux \
    && install_zsh \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi

