# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

### Cross-platform

- **Shell** - zsh (primary), fish, bash with [starship](https://starship.rs/) prompt
- **Editor** - [Neovim](https://neovim.io/) with LazyVim framework
- **Terminal** - alacritty, ghostty
- **Multiplexer** - tmux, zellij
- **Git** - aliases, conditional includes for work/personal
- **Fonts** - JetBrains Mono Nerd Font
- **Version manager** - [mise](https://mise.jbang.dev/) (node, python, java)
- **Keyboard** - [kanata](https://github.com/jtroo/kanata) (cross-platform remapper)

### macOS

- [AeroSpace](https://github.com/nikitabobko/AeroSpace) - tiling window manager
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) - keyboard customization
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) - status bar
- Ghostty terminal

### Linux

- [i3](https://i3wm.org/) - tiling window manager (X11)
- [Sway](https://swaywm.org/) - tiling window manager (Wayland)
- [Polybar](https://polybar.github.io/) - status bar (i3)
- [Waybar](https://github.com/Alexays/Waybar) - status bar (Sway)
- [Rofi](https://github.com/davatorium/rofi) - application launcher
- GTK3 theme, X11 resources, wallpapers

## Install

### macOS

Install Homebrew packages and casks:

```bash
./install_mac.sh
```

This will:
- Install [Homebrew](https://brew.sh/) if not present
- Install CLI packages from `brew.txt`
- Install GUI apps from `brew-cask.txt`

### Arch Linux

```bash
./install_arch.sh
```

Installs core tools, i3 desktop, terminal, shell, neovim, networking, audio (pipewire), and graphics drivers.

### Ubuntu / Debian

```bash
./install_ubuntu.sh
```

Modular install with optional functions: `install_basics`, `install_shell`, `install_search`, `install_rust`, `install_i3status`, `install_sway`, `install_sound`, `install_nvidia`, `install_power`.

## Configure

### Using stow (recommended)

Since the repo is not directly in `$HOME`, always pass `-t $HOME`:

```bash
stow -t $HOME <package>
```

Packages are platform-specific. Pick what matches your OS:

**Common (macOS + Linux):**

```bash
stow -t $HOME zsh git nvim tmux starship alacritty mise scripts kanata ghostty fish bash zellij fonts claude
```

**macOS only:**

```bash
stow -t $HOME aerospace karabiner sketchybar
```

**Linux only:**

```bash
stow -t $HOME i3 polybar rofi sway waybar gtk-3.0 x x11 pictures
```

### Using configure.sh

Alternative script that creates symlinks manually and installs zsh plugins:

```bash
./configure.sh          # everything (Linux-oriented)
./configure.sh neovim   # single component
```

### Change default shell

```bash
chsh -s $(which zsh)
```

## Fonts

```bash
mkdir -p ~/.local/share/fonts
cp fonts/nerdfonts/JetBrainsMonoNerd/*.ttf ~/.local/share/fonts/
fc-cache -fv
```

On Arch, also install emoji support: `sudo pacman -S noto-fonts-emoji`

Verify icons display correctly:

```bash
echo -e "\xf0\x9f\x90\x8d"   # snake
echo -e "\xee\x82\xa0"       # git branch
```

## Tmux

Install [TPM](https://github.com/tmux-plugins/tpm) (plugin manager):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then inside tmux, press `ctrl-A + I` to install plugins.

Check 24-bit color support:

```bash
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash
```

## Neovim

See [nvim/README.md](./nvim/README.md) for detailed setup (LSP, DAP, AI integrations).

## macOS extras

### Sign native nvim libraries

After installing neovim plugins with native libraries, sign them:

```bash
find ~/.local/share/nvim -name "*.so" | while read lib; do
  sudo codesign --force --sign - "$lib"
done
```

### Key tools

- **AeroSpace** - tiling WM with vi-key bindings (`alt-hjkl`)
- **Karabiner** - caps-lock remapping and custom shortcuts
- **SketchyBar** - customizable status bar
- **Raycast** - launcher (replaces Spotlight)

## Linux extras

### i3 window manager

Configs include polybar, rofi menus, and wallpaper setup. Multi-monitor layout script available at `.local/bin/monitor_layout`.

### Sway (Wayland)

Alternative to i3 for Wayland sessions, with waybar status bar.

### HiDPI / X11

Adjust DPI in `.Xresources`. See [Arch wiki on HiDPI](https://wiki.archlinux.org/title/HiDPI#X_Server).

```bash
xdpyinfo | grep -B 2 resolution
```
