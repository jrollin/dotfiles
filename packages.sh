#!/usr/bin/env bash

install_basics() {
    apt install git unzip curl xclip build-essential cmake
}

install_search() {
echo "Installing packages..." \
    && apt install ripgrep fzf  
}

install_shell() {
    echo "installing shell..." \
        && apt install zsh xterm tmux \
        && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_i3status() {
    echo "installing status tools..." \
        && apt install rofi flameshot feh xbacklight
}

install_sound() {
    echo "installing sound.." \
        && apt install alsa-tools pavucontrol
}

install_blue() {
    echo "installing blue.." \
        && apt install blueman
}

if [[ -z $1 ]]; then
  echo -n "This will install packages, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    && install_basics  \
    && install_shell \
    && install_search \
    && install_i3status \
    && install_sound \
    && install_blue \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi
