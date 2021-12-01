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

### Tip - hidden files

By default, `rg` does not search hidden files. If you want to edit hidden files (dotfiles) and see the output of the `cmp-rg` completion source, you should pass the flag `--hidden` to `rg`. Your configuration could then look like this:

```
    ...
    {
        name = 'rg',
        option = {additional_arguments = '--hidden'},
    }
    ...
```

### Tip - recursion limit

`rg` does not have a directory recursion limit. This means that if you start your `nvim` instance from your `~` folder (or any folder that has many subfolder layers) `rg-cmp` could considerably slow down your system. To set a recursion limit to `n`, add the flag `--max-depth n` to `additional_arguments`. Your configuration could then look like this:


```
    ...
    {
        name = 'rg',
        option = {additional_arguments = '--max-depth 4'},
    }
    ...
```

## Screenshot

![Screenshot](https://user-images.githubusercontent.com/12900252/143555260-8567fb04-eea6-4a73-a1dc-d36d4df8cb64.png)
