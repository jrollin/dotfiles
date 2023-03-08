#!/usr/bin/env bash

install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf $HOME/.config/nvim $HOME/.fzf \
  && ln -s $(pwd)/nvim $HOME/.config/nvim 
}

install_window() {
    echo "installing_window.." \
        && rm -rf $HOME/.config/gtk-3.0 \
        && ln -s $(pwd)/gtk-3 $HOME/.config/gtk-3.0
}


install_i3() {
    echo "installing_i3.." \
        && rm -rf $HOME/.config/i3 \
        && ln -s $(pwd)/i3 $HOME/.config/i3  
}

install_i3_wallpaper() {
    echo "installing_i3wallper.." \
        && rm -rf $HOME/.config/pictures \
        && ln -s $(pwd)/pictures $HOME/.config/pictures  
}

install_i3menu() {
    echo "installing_i3menu.." \
        && rm -rf $HOME/.config/rofi \
        && ln -s $(pwd)/rofi $HOME/.config/rofi  
    echo "installing_polybar.." \
        && rm -rf $HOME/.config/polybar \
        && ln -s $(pwd)/polybar $HOME/.config/polybar  
}

install_monitor() {
    echo "installing_monitor.." \
        && rm -rf $HOME/.config/monitor_layout.sh \
        && ln -s $(pwd)/monitor_layout.sh $HOME/.config/monitor_layout.sh
}

install_tmux() {
    echo "installing tmux conf" \
        && rm -f $HOME/.tmux.conf \
        && ln -s $(pwd)/.tmux.conf $HOME/.tmux.conf 
    echo "installing tmux tpm" \
        && rm -rf $HOME/.tmux \
        && ln -s $(pwd)/tmux $HOME/.tmux
    echo "installing zellij" \
        && rm -rf $HOME/.config/zellij \
        && ln -s $(pwd)/zellij $HOME/.config/zellij
 }

install_zsh() {
    echo "installing zsh" \
        && rm -f $HOME/.zshrc \
        && ln -s $(pwd)/.zshrc $HOME/.zshrc \
        && mkdir -p "$HOME/.cache/zsh"

    echo "Installing zsh theme..." \
        && rm -rf $HOME/.config/dracula.zsh-theme \
        && git clone https://github.com/dracula/zsh.git $HOME/.config/dracula.zsh-theme \
        && rm -f $HOME/.oh-my-zsh/themes/dracula.zsh-theme \
        && ln -s $HOME/.config/dracula.zsh-theme/dracula.zsh-theme  $HOME/.oh-my-zsh/themes/dracula.zsh-theme
}

install_term() {
    echo "installing term" \
        && rm -rf $HOME/.config/alacritty \
        && ln -s $(pwd)/alacritty $HOME/.config/alacritty 

    cargo install alacritty 
    
    echo "installing starship" \
        && rm -rf $HOME/.config/starship.toml \
        && ln -s $(pwd)/starship.toml $HOME/.config/starship.toml

    cargo install starship --locked
}

install_ts() {
    echo "Installing ts..." \
        && npm install -g typescript typescript-language-server prettier 
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
    && install_window \
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

