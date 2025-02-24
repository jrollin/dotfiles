#!/usr/bin/env bash

install_basics() {
    apt install \
      git \
      unzip \
      curl \
      zsh \
      xclip \
      tree \
      direnv \
      xdg-utils \
      sshpass \
      cmake \
      build-essential \
      # tools
      # most larges files
      ncdu 
}

install_search() {
echo "Installing packages..." \
    && apt install ripgrep fzf  fd-find
}

install_shell() {
    echo "installing shell..." \
        && apt install fish tmux direnv
}

install_rust() {
    echo "installing rust..." \
        && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3  libssl-dev
}

install_i3status() {
    echo "installing status tools..." \
        && apt install rofi flameshot feh dmenu polybar
}

install_sound() {
    # remplace pulseaudio by pipewire (ubuntu 22.04 )
    echo "installing pipewire.." \
             #https://gist.github.com/the-spyke/2de98b22ff4f978ebf0650c90e82027e
             # remove session and add wireplumber
             && apt-get install pipewire-media-session- pipewire-pulse wireplumber \
             && systemctl --user --now enable wireplumber.service

    echo "installing alsa plugin.." \
        && apt install pipewire-audio-client-libraries \
        &&  cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

    echo "installing alsa plugin.." \
       # remove pulseaudio bluetooth
       && apt install libldacbt-{abr,enc}2 libspa-0.2-bluetooth pulseaudio-module-bluetooth-

    echo "installing audio control.." \
          && apt pavucontrol


    ### check config ok
    #$  LANG=C pactl info | grep '^Server Name'

}

install_blue() {
    echo "installing blue.." \
        && apt install blueman
}

install_utils() {
    echo "installing utils.." \
    && apt install tldr htop  jq socat
}

install_laptop() {
    echo "installing laptop.." \
    && apt install brightnessctl xbacklight lm-sensors
}

install_sway() {
    echo "installing sway.." \
    && apt install sway swaylock \
    clipman \
    waybar \ 
    # notif
    mako
}

install_nvidia(){
    # glxinfo
    apt-get install hwinfo mesa-utils

    #infos 
    #hwinfo --gfxcard --short
}

install_power(){
    # sudo add-apt-repository -y ppa:linuxuprising/apps
    # sudo apt update
    # sudo apt install tlpui

    apt tlp powertop thermald

    # ps: enable each service 
    # sudo systemctl enable --now thermald
}

if [[ -z $1 ]]; then
  echo -n "This will install packages, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing dependencies..." \
    && install_basics  \
    && install_shell \
    && install_rust \
    && install_search \
    && install_i3status \
    && install_sound \
    && install_blue \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi
