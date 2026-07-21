# Nvim readme

## Requirements

in Neovim on new machine

```vim
:Lazy restore
```

## Ruby LSP

`ruby_lsp` runs a global `ruby-lsp` (resolved from `PATH`) against a stub gemfile, so
it never touches a project's own bundle. This is required for EOL-Ruby projects (e.g.
Ruby 2.7) where modern `ruby-lsp` cannot install into the project's Ruby.

Per-machine setup (macOS and Linux):

```bash
# 1. install ruby-lsp on a modern Ruby (>= 3.0)
gem install ruby-lsp

# 2. create the stub gemfile the LSP is pinned to
mkdir -p ~/.config/ruby-lsp
echo 'source "https://rubygems.org"' > ~/.config/ruby-lsp/Gemfile
```

If `ruby-lsp` is not on `PATH`, the server is skipped silently.

## Digraph

display all non ASCII symbols (digraph)

```bash
hdigraphs
```

## Debug with Dap

requirements :

- Mason plugin
- Nvim plugin "mfussenegger/nvim-dap"

### PHP xdebug 3

Install `php-debug-adapter` with Mason

Rely on Microsoft Vscode php plugin

```bash
cd $HOME
git clone https://github.com/xdebug/vscode-php-debug
cd vscode-php-debug
npm install
npm build
```

Configure dap adapter for php

```yaml
dap.adapters.php = {
type = "executable",
command = "node",
args = { os.getenv("HOME") .. "/vscode-php-debug/out/phpDebug.js" },
}
dap.configurations.php = {
{
type = "php",
request = "launch",
name = "Listen for Xdebug",
port = 9003,
},
}
```

- xdebug 3 config

```text
xdebug.mode=debug
xdebug.start_with_request=yes
```

### Node JS

> source: <https://www.darricheng.com/posts/setting-up-nodejs-debugging-in-neovim/>

install `js-debug-adapter` with Mason

Rely on Miscrosoft vscode plugin : <https://github.com/microsoft/vscode-js-debug>
