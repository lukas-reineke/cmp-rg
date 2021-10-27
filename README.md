# cmp-rg

[ripgrep](https://github.com/BurntSushi/ripgrep) source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## Dependencies

You need to have [ripgrep](https://github.com/BurntSushi/ripgrep) installed.

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

## Screenshot

![Screenshot](https://user-images.githubusercontent.com/12900252/138992645-7db2f717-be48-44a8-8342-daa01400c45c.png)
