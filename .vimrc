set rtp^=~/.vim/
let mapleader = "\<Space>"
inoremap yy <ESC>
vnoremap <ESC> <C-c>
vnoremap . :norm.<CR>
map <C-k> <Plug>(easymotion-F)
map <C-j> <Plug>(easymotion-f)
nnoremap <Leader><Esc> <C-w>
set clipboard=unnamed
set nofoldenable

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

autocmd! bufwritepost .vimrc source %

let g:pathogen_disabled = []

if !executable('nim')
    call add(g:pathogen_disabled, 'nvim-nim')
endif

if !has("nvim")
    call add(g:pathogen_disabled, 'Neomake')
endif

execute pathogen#infect()

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

syntax enable
colorscheme dracula
highlight Identifier ctermfg=255
highlight ErrorMsg ctermfg=231 ctermbg=124
set nofoldenable

set number

let termapp = $TERM_PROGRAM
if termapp=~"iTerm.app"
    let &t_SI = "\<Esc>]1337;CursorShape=1\x7"
    let &t_EI = "\<Esc>]1337;CursorShape=0\x7"
endif

"autocmd! BufRead * Neomake
"autocmd! BufWritePost * Neomake
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

nnoremap <Leader>nr :! nim c -r --threads:on --verbosity:0 %<CR>
nnoremap <Leader>ni :! nim c -d:release --threads:on "-o:$NIMBIN/"`basename "%" .nim` "%"<CR>
nnoremap <Leader>no :NimOutline<CR>

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

au BufNewFile,BufRead *.nim set filetype=nim
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['nim'] = ['.']
let g:ycm_auto_trigger = 0
let g:ycm_min_num_identifier_candidate_chars = 2
