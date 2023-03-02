#/bin/sh

# base
pacman -S \ 
  git \
  unzip \
  curl \
  zsh \
  xclip \
  tree \
  direnv \
  base-devel \
  xdg-utils \
  cmake

# i3 
pacman -S \
  polybar \
  rofi \
  alacritty \
  flameshot \
  feh \
  xorg-xbacklight \
  i3lock

#xorg intel
## Install Intel graphic drivers
pacman -S xf86-video-intel

# vim
pacman -S \
  neovim \
  ripgrep \
  fzf 


# network 
pacman -S \
  networkmanager \
  iw \
  wpa_supplicant \
  wireless_tools \
  netctl \
  bluez \
  bluez-utils 

# sound
pacman -S \
  pulseaudio-bluetooth \
  pulseaudio-alsa \
  pavucontrol

