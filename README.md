# Dotfiles

My config

- nvim
- i3 / demnu / polybar / rofi
- tmux
- zsh / alacritty / starship
- fonts Nerd with icons
- arch / lightdm

## Requirements

I3wm

```
sudo pacman -S i3-wm
```

Configure touchpad and brightness touch for lib xorg

[My Dell xorg gist](https://gist.github.com/jrollin/1208610469474c4315a1f9d6c3e1da8c)

## Get infos

get infos about machine setup with [neofetch](https://github.com/dylanaraps/neofetch)

```Bash
neofetch
```

or with inxi

```Bash
inxi -Fxxxrz

System:
  Kernel: 6.1.12-1-MANJARO arch: x86_64 bits: 64
    compiler: gcc v: 12.2.1 Desktop: i3 v: 4.22 info: polybar
    vt: 7 dm: LightDM v: 1.32.0 Distro: Manjaro Linux
    base: Arch Linux
Machine:
  Type: Laptop System: Dell product: XPS 13 9305 v: N/A
```

X config

```Bash
xset q
```

## Install

Os packages (tmux, rust, etc)

```
./install_arch.sh
```

Configure tools with my config and make symlinks

```
./configure.sh
```

## fonts

```Bash
mkdir -p ~/.local/share/fonts
cp fonts/JetBrainsMonoNerd/*.ttf ~/.local/share/fonts/
fc-cache -fv
```

> requires a noto font with emoji (on arch : `noto-fonts-emoji`)

Check if font is ok

```bash
echo -e "\xf0\x9f\x90\x8d"
echo -e "\xee\x82\xa0"
```

you should see snake icon and branch icon

## tmux

Install tpm

```Bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Dans tmux, `ctrl-A +  I` pour installer les plugins

check colors with this script

```Bash
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash
```

## Neovim

### Requirements

in Neovim on new machine

```vim
:Lazy restore
```

### Digraph

display all non ASCII symbols (digraph)

```
:digraphs
```

Usage: `<C-K> code`

## Xserver

DPi adjust with `.Xresources`

https://wiki.archlinux.org/title/HiDPI#X_Server

```Bash
xdpyinfo | grep -B 2 resolution

screen #0:
  dimensions:    1920x1080 pixels (293x165 millimeters)
  resolution:    166x166 dots per inch
```

[more info about dpi](https://linuxreviews.org/HOWTO_set_DPI_in_Xorg)

Chrome

    Go to chrome://flags

    Search "Preferred Ozone platform"

    Set it to "Wayland"

    Restart
