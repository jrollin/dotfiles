# Dotfiles

My config for Ubuntu 22.04

* nvim 
* i3 / demnu / polybar / rofi
* tmux 
* zsh / alacritty / starship
* fonts Nerd with icons


## Requirements 


I3wm

```
sudo apt install i3
```

Configure touchpad and brightness touch for lib xorg

[My Dell xorg gist](https://gist.github.com/jrollin/1208610469474c4315a1f9d6c3e1da8c)


## Install 

Os packages (tmux, rust, etc)

```
./packages.sh
```

Configure tools with my config and make symlinks 

```
./install.sh
```

## fonts


```Bash
mkdir -p ~/.local/share/fonts
cp fonts/JetBrainsMonoNerd/*.ttf ~/.local/share/fonts/ 
fc-cache -fv
```

## tmux

check colors with this script 

```Bash
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash
```


## console setup

If not alacritty as default term 

```Bash
sudo dpkg-reconfigure console-setup
```
=> choose Terminus


## Alacritty as defaut

```
sudo update-alternatives --config x-terminal-emulator
```



## Neovim Tips


### Digraph

display all non ASCII symbols (digraph)

```
:digraphs
```

Usage:  `<C-K> code`


