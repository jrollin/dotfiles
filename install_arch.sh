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
  cmake \
  sshpass

# i3 
pacman -S \
  polybar \
  rofi \
  flameshot \
  feh \
  xorg-xbacklight \
  i3lock

# term / shell
pacman -S \
  alacritty \
  starship \
  fish

# utils
pacman -S \
    tldr \
    htop \
    imagemagick \
    jq

#xorg intel
## Install Intel graphic drivers
pacman -S \
    xf86-video-intel \
    intel-media-driver  


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
  pipewire-{audio,jack,alsa,pulse} \
  wireplumber \
  xdg-desktop-portal-gtk \
  pavucontrol


# test hardware aceleration :
# mpv --hwdec=auto PATH/videofile
# vainfo
# glxinfo | grep "direct rendering"
sudo pacman -S \
    mpv \
    libva-utils \
    vdpauinfo \
    glxinfo  
