# Nvim readme

## Requirements

in Neovim on new machine

```vim
:Lazy restore
```

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
