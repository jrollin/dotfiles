#!/usr/bin/env bash
install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf ~/.config/nvim ~/.fzf \
  && ln -s $(pwd)/nvim ~/.config/nvim 
}

install_i3() {
    echo "installing_i3.." \
        && rm -rf ~/.config/i3 \
        && ln -s $(pwd)/i3 ~/.config/i3  
}

install_i3_wallpaper() {
    echo "installing_i3wallper.." \
        && rm -rf ~/.config/pictures \
        && ln -s $(pwd)/pictures ~/.config/pictures  
}

install_i3menu() {
    echo "installing_i3menu.." \
        && rm -rf ~/.config/rofi \
        && ln -s $(pwd)/rofi ~/.config/rofi  
    echo "installing_polybar.." \
        && rm -rf ~/.config/polybar \
        && ln -s $(pwd)/polybar ~/.config/polybar  
}


install_tmux() {
    echo "installing tmux" \
        && rm -f ~/.tmux.conf \
        && ln -s $(pwd)/tmux/.tmux.conf ~/.tmux.conf 
 }

install_zsh() {
    echo "installing zsh" \
        && rm -f ~/.zshrc \
        && ln -s $(pwd)/.zshrc ~/.zshrc
}

install_term() {
    echo "installing term" \
        && rm -rf ~/.config/alacritty \
        && ln -s $(pwd)/alacritty ~/.config/alacritty 

    cargo install alacritty 
    
    echo "installing starship" \
        && rm -rf ~/.config/starship.toml \
        && ln -s $(pwd)/starship.toml ~/.config/starship.toml

    cargo install starship
}

install_ts() {
    echo "Installing ts..." \
        && npm install -g typescript typescript-language-server prettier 
}

install_asdf(){
    echo "Installing Asdf..." \
    && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
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
    && install_tmux \
    && install_zsh \
    && install_term \
    && install_ts \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi

