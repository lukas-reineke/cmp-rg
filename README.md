# cmp-rg

[ripgrep](https://github.com/BurntSushi/ripgrep) source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## Dependencies

You need to have `rg` and `sort` installed.

## Install

Use your favourite plugin manager to install.

#### Example with Packer

[wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
-- init.lua
require("packer").startup(
    function()
        use "lukas-reineke/cmp-rg"
    end
)
```

#### Example with Plug

[junegunn/vim-plug](https://github.com/junegunn/vim-plug)

```vim
" init.vim
call plug#begin('~/.vim/plugged')
Plug 'lukas-reineke/cmp-rg'
call plug#end()
```

## Setup

Add `rg` to your cmp sources

```lua
require'cmp'.setup {
    sources = {
        { name = 'rg' }
    }
}
```

For more options see `:help cmp-rg`
