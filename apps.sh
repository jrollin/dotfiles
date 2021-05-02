#!/usr/bin/env bash

install_design() {
    echo "installing design app..." \
        && curl -LO https://inkscape.org/gallery/item/23849/Inkscape-e86c870-x86_64.AppImage \
        && mv Inkscape-e86c870-x86_64.AppImage ~/Inkscape.AppImage \
        && chmod u+x ~/Inkscape.AppImage

}


install_stream() {
    # obs for stream recording
    echo "installing video app..." \
        && add-apt-repository ppa:obsproject/obs-studio \
        && apt update \
        && apt install obs-studio 
}

install_video() {
    # peek for gif video recoarding
    echo "installing video app..." \
        && curl -LO https://github.com/phw/peek/releases/download/1.3.1/peek-1.3.1-0-x86_64.AppImage\
        && mv peek-1.3.1-0-x86_64.AppImage ~/peek.AppImage \
        && chmod u+x ~/peek.AppImage
}

install_3D() {
    echo "installing 3D app..." \
        && curl -LO https://www.blender.org/download/Blender2.92/blender-2.92.0-linux64.tar.xz
}

if [[ -z $1 ]]; then
  echo -n "This will install all apps, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing apps..." \
    && install_design  \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi
