set rtp^=~/.vim/
let mapleader = "\<Space>"
inoremap yy <ESC>
vnoremap <ESC> <C-c>
vnoremap . :norm.<CR>
map <C-k> <Plug>(easymotion-F)
map <C-j> <Plug>(easymotion-f)
nnoremap <Leader><Esc> <C-w>
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

set number

let termapp = $TERM_PROGRAM
if termapp=~"iTerm.app"
    let &t_SI = "\<Esc>]1337;CursorShape=1\x7"
    let &t_EI = "\<Esc>]1337;CursorShape=0\x7"
endif

autocmd! BufRead * Neomake
autocmd! BufWritePost * Neomake
"let g:nvim_nim_enable_default_binds = 0

let g:neomake_warning_sign = {
  \ 'text': 'W',
  \ 'texthl': 'WarningMsg',
  \ }
let g:neomake_error_sign = {
  \ 'text': 'E',
  \ 'texthl': 'ErrorMsg',
  \ }
let g:neomake_info_sign = {
  \ 'text': 'I',
  \ 'texthl': 'InfoMsg',
  \ }

nnoremap <Leader>nr :! nim c -r --verbosity:0 %<CR>
