#!/usr/bin/env bash
install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf ~/.config/nvim ~/.fzf \
  && ln -s $(pwd)/nvim ~/.config/nvim 
}

install_packages() {
echo "Installing packages..." \
    && apt install ripgrep fzf
}

install_i3() {
    echo "installing_i3.." \
        && rm -rf ~/.config/i3 \
        && ln -s $(pwd)/i3 ~/.config/i3  
}

install_ts() {
    npm install -g typescript typescript-language-server prettier 
}


if [[ -z $1 ]]; then
  echo -n "This will delete all your previous nvim, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    install_neovim \
    && install_ts \
    && install_packages \
    && install_i3 \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi

