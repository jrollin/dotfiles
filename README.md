# dotfiles

* nvim 
* i3
* tmux
* zsh


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

```Bash
sudo dpkg-reconfigure console-setup
```

choose Terminus



## Neovim Tips


### Digraph

display all non ASCII symbols (digraph)

```
:digraphs
```

Usage:  `<C-K> code`


