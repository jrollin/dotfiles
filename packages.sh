#!/usr/bin/env bash

install_basics() {
    apt install git unzip curl ffmpeg xclip
}

install_search() {
echo "Installing packages..." \
    && apt install ripgrep fzf  
}

install_shell() {
    echo "installing shell..." \
        && apt install zsh terminator tmux \
        && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

if [[ -z $1 ]]; then
  echo -n "This will install packages, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    && install_basics  \
    && install_shell \
    && install_search \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi
