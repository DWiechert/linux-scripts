Installed [NeoVim](https://neovim.io/) for MacOS by following:
- https://dev.to/dafloresdiaz/neovim-for-macos-3nk0

If config file does not exist, create it manually:
```
cd ~/.config/
mkdir nvim
cd nvim/
wget https://raw.githubusercontent.com/DWiechert/linux-scripts/master/configs/nvim/init.vim
```

Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug).

Open one file to have vim-plug install plug-ins:
```
nvim init.vm
```

Could not use NeoVim color schemes while using Oh-my-zsh:
- https://stackoverflow.com/questions/37081223/why-colors-are-not-displaying-in-vim-oh-my-zsh

Ended up switching to iTerm2 on MacOS and installing custom color scheme there:
- https://iterm2colorschemes.com/
- https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Wryan.itermcolors
