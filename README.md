# dotfiles

* nvim 
* i3
* tmux
* zsh


## fonts

mkdir ~/.local/share/fonts
cp fonts/JetBrainsMono/*.ttf ~/.local/share/fonts/ 
fc-cache -fv

## console setup


sudo dpkg-reconfigure console-setup

choose Terminus


## rust

* [lldb](https://lldb.llvm.org/) for debug
* [vscode llDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) 

  >  GDB and LLDB aren't Rust aware
  >  Rust provides rust-gdb and rust-lldb wrappers

