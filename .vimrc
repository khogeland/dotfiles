let mapleader = "\<Space>"
inoremap yy <ESC>
vnoremap <ESC> <C-c>
vnoremap . :norm.<CR>
map <C-k> <Plug>(easymotion-F)
map <C-j> <Plug>(easymotion-f)

set clipboard=unnamed

autocmd! bufwritepost .vimrc source %
execute pathogen#infect()

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

syntax enable
colorscheme monokai
set background=dark

set rnu
set number
