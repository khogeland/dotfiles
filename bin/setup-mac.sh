#!zsh

set -x
set -e

git submodule update --init --recursive
require brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install fd fzf bat coreutils ctags neovim autojump
p="$PWD"
cd ~/.vim/bundle/deoplete.nvim
python3 -m pip install --upgrade -r test/requirements.txt
cd "$p"
python3 -m pip install neovim neovim-remote
