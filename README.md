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
require("packer").startup(function()
    use "lukas-reineke/cmp-rg"
end)
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
require("cmp").setup {
    sources = {
        {
            name = "rg",
            -- Try it when you feel cmp performance is poor
            -- keyword_length = 3
        },
    },
}
```

For more options see `:help cmp-rg`

## Screenshot

<img width="900" src="https://user-images.githubusercontent.com/12900252/143555260-8567fb04-eea6-4a73-a1dc-d36d4df8cb64.png" alt="Screenshot" />
