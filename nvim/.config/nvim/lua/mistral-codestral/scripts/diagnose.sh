#!/bin/bash
# Quick diagnostic script for Mistral completions

echo "Running Mistral Codestral diagnostics..."
echo ""

# Run diagnostics in Neovim
nvim --headless -u ~/.config/nvim/init.lua \
  -c "luafile ~/.config/nvim/lua/mistral-codestral/scripts/debug_completion.lua" \
  -c "lua require('mistral-codestral.scripts.debug_completion').diagnose()" \
  -c "qa" 2>&1

echo ""
echo "To run diagnostics interactively:"
echo "1. Open Neovim with a file: nvim /tmp/test.js"
echo "2. Run: :luafile ~/.config/nvim/lua/mistral-codestral/scripts/debug_completion.lua"
echo "3. Run: :DiagnoseMistral"
