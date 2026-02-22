#!/bin/zsh

# Install homebrew if not present
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install all homebrew packages
while IFS='' read -r line || [[ -n "$line" ]]; do
	[[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
	brew install "$line"
done <"./brew.txt"

while IFS='' read -r line || [[ -n "$line" ]]; do
	[[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
	brew install --cask "$line"
done <"./brew-cask.txt"

stow nvim -t "$HOME"

# speech
# https://macparakeet.com
#
# store keychain
# ssh-add --apple-use-keychain ~/.ssh/id_ed25519
