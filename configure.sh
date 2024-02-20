#!/usr/bin/env bash
DOTFILES_PATH=$(pwd)
ZSH_PLUGINS=$XDG_CONFIG_HOME/zsh-plugins

install_scripts() {
    echo "Setting local scripts .." 
    # monitor
    rm -f $HOME/.local/bin/monitor_layout \
    && ln -s $DOTFILES_PATH/scripts/monitor_layout $HOME/.local/bin/monitor_layout 
    # tm
    rm -f $HOME/.local/bin/tm \
    && ln -s $DOTFILES_PATH/scripts/tm $HOME/.local/bin/tm 
    # virtualcam
    rm -f $HOME/.local/bin/virtualcam  \
    && ln -s $DOTFILES_PATH/scripts/virtualcam $HOME/.local/bin/virtualcam
}

install_neovim() {
  echo "Setting up neovim..." \
  && rm -rf $XDG_CONFIG_HOME/nvim $HOME/.fzf \
  && ln -s $DOTFILES_PATH/nvim $XDG_CONFIG_HOME/nvim 
}

install_git() {
    echo "installing git" \
        && rm -f $HOME/.gitconfig \
        && ln -s $DOTFILES_PATH/git/.gitconfig $HOME/.gitconfig 
}

install_i3() {
    echo "installing_i3.." \
        && rm -rf $XDG_CONFIG_HOME/i3 \
        && ln -s $DOTFILES_PATH/i3 $XDG_CONFIG_HOME/i3  
}
install_sway() {
    echo "installing_sway.." \
        && rm -rf $XDG_CONFIG_HOME/sway \
        && ln -s $DOTFILES_PATH/sway $XDG_CONFIG_HOME/sway
    echo "installing_swaybar.." \
        && rm -rf $XDG_CONFIG_HOME/waybar \
        && ln -s $DOTFILES_PATH/waybar $XDG_CONFIG_HOME/waybar
}

install_wallpaper() {
    echo "installing_i3wallper.." \
        && rm -rf $XDG_CONFIG_HOME/pictures \
        && ln -s $DOTFILES_PATH/pictures $XDG_CONFIG_HOME/pictures  
}

install_menu() {
    echo "installing_i3menu.." \
        && rm -rf $XDG_CONFIG_HOME/rofi \
        && ln -s $DOTFILES_PATH/rofi $XDG_CONFIG_HOME/rofi  
    echo "installing_polybar.." \
        && rm -rf $XDG_CONFIG_HOME/polybar \
        && ln -s $DOTFILES_PATH/polybar $XDG_CONFIG_HOME/polybar  
}

install_monitor() {
    echo "installing_monitor.." \
        && rm -rf $XDG_CONFIG_HOME/monitor_layout.sh \
        && ln -s $DOTFILES_PATH/monitor_layout.sh $XDG_CONFIG_HOME/monitor_layout.sh
}

install_tmux() {
    echo "installing tmux tpm" \
        && rm -rf $XDG_CONFIG_HOME/tmux \
        && ln -s $DOTFILES_PATH/tmux $XDG_CONFIG_HOME/tmux
 }

install_bash() {
    echo "installing bashrc" \
        && rm -f $HOME/.bashrc \
        && ln -s $DOTFILES_PATH/bash/.bashrc $HOME/.bashrc 

    echo "installing bash profile" \
        && rm -f $HOME/.bash_profile \
        && ln -s $DOTFILES_PATH/bash/.bash_profile $HOME/.bash_profile 

    echo "installing bashrc files" \
        && rm -f $HOME/.bashrc_{alias,env,path} \
        && ln -s $DOTFILES_PATH/bash/.bashrc_alias $HOME/.bashrc_alias \
        && ln -s $DOTFILES_PATH/bash/.bashrc_env $HOME/.bashrc_env \
        && ln -s $DOTFILES_PATH/bash/.bashrc_path $HOME/.bashrc_path 
}

install_zsh() {
    echo "installing zsh" \
        && rm -f $HOME/.zshrc \
        && ln -s $DOTFILES_PATH/zsh/.zshrc $HOME/.zshrc \
        && mkdir -p "$HOME/.cache/zsh"

    echo "installing zsh env" \
        && rm -f $HOME/.zshenv \
        && ln -s $DOTFILES_PATH/zsh/.zshenv $HOME/.zshenv 

    echo "installing zsh profile" \
        && rm -f $HOME/.zprofile \
        && ln -s $DOTFILES_PATH/zsh/.zprofile $HOME/.zprofile 
    
    echo "installing zsh alias" \
        && rm -f $XDG_CONFIG_HOME/zsh  \
        && ln -s $DOTFILES_PATH/zsh/.config $XDG_CONFIG_HOME/zsh 
    
    echo "installing zsh plugins dir" \
        && rm -rf $ZSH_PLUGINS \
        && mkdir -p $ZSH_PLUGINS
}

install_zsh_plugins() {

    echo "Installing zsh autosuggestions..." \
        && rm -rf $ZSH_PLUGINS/zsh-autosuggestions \
        && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PLUGINS/zsh-autosuggestions  \
        && rm -f $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
        && ln -s $ZSH_PLUGINS/zsh-autosuggestions  $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions

    echo "Installing zsh zsh-syntax-highlighting..." \
        && rm -rf $ZSH_PLUGINS/zsh-syntax-highlighting \
        && git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_PLUGINS/zsh-syntax-highlighting  \
        && rm -f $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
        && ln -s $ZSH_PLUGINS/zsh-syntax-highlighting  $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    echo "Installing zsh theme..." \
        && rm -rf $ZSH_PLUGINS/dracula.zsh-theme \
        && git clone https://github.com/dracula/zsh.git $ZSH_PLUGINS/dracula.zsh-theme \
        && rm -f $HOME/.oh-my-zsh/themes/dracula.zsh-theme \
        && ln -s $ZSH_PLUGINS/dracula.zsh-theme/dracula.zsh-theme  $HOME/.oh-my-zsh/themes/dracula.zsh-theme
}

install_term() {
    echo "installing term" \
        && rm -rf $XDG_CONFIG_HOME/alacritty \
        && ln -s $DOTFILES_PATH/alacritty $XDG_CONFIG_HOME/alacritty 
    
    echo "installing starship" \
        && rm -rf $XDG_CONFIG_HOME/starship \
        && ln -s $DOTFILES_PATH/starship $XDG_CONFIG_HOME/starship
}

install_nix() {
    echo "installing nix" \
        && rm -rf $XDG_CONFIG_HOME/nix \
        && ln -s $DOTFILES_PATH/nix $XDG_CONFIG_HOME/nix 
    
}
install_x(){

    echo "installing xdefault" \
        && rm -rf $XDG_CONFIG_HOME/.Xdefaults \
        && ln -s $DOTFILES_PATH/.Xdefaults $XDG_CONFIG_HOME/.Xdefaults 
    
    echo "installing xresources" \
        && rm -rf $XDG_CONFIG_HOME/.Xresources \
        && ln -s $DOTFILES_PATH/.Xresources $XDG_CONFIG_HOME/.Xresources

}

install_gtk() {
    echo "installing gtk3" \
        && rm -rf $XDG_CONFIG_HOME/gtk-3.0 \
        && ln -s $DOTFILES_PATH/gtk-3.0 $XDG_CONFIG_HOME/gtk-3.0 
}
install_ts() {
    echo "Installing ts..." \
        && npm install -g typescript prettier neovim
}

install_asdf(){
    echo "Installing Asdf..." \
    && git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.11.1
    # nodejs
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs latest
    asdf global nodejs latest
}

if [[ -z $1 ]]; then
  echo -n "This will delete all your previous nvim, Proceed? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    echo "Installing ..." \
    && install_scripts \
    && install_neovim \
    && install_git \
    && install_i3 \
    && install_x \
    && install_wallpaper\
    && install_menu \
    && install_monitor \
    && install_tmux \
    && install_bash \
    && install_gtk \
    && echo "Finished installation."
  fi
else
  "install_$1" $1
fi

