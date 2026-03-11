#! /bin/bash
find ~/.local/share/nvim -name "*.so" -o -name "*.dylib" | while read lib; do
	sudo codesign --force --sign - "$lib"
done
