inoremap jj <ESC>
let mapleader = "\<Space>"
vnoremap <ESC> <C-c>
vnoremap . :norm.<CR>
set rnu

set clipboard=unnamedplus

autocmd! bufwritepost .vimrc source %
execute pathogen#infect()

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab

syntax enable
colorscheme monokai
set background=dark

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
