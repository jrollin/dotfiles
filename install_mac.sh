# 
# Install all homebrew packages
while IFS='' read -r line || [[ -n "$line" ]]; do
	brew install "$line"
done <"./brew.txt"

stow nvim -t "$HOME"
