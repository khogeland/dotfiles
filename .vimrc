autocmd! bufwritepost .vimrc source %

set rtp^=~/.vim/
let mapleader = "\<Space>"
inoremap yy <ESC>
tnoremap yy <C-\><C-n>
vnoremap <ESC> <C-c>
vnoremap . :norm.<CR>
map <C-k> <Plug>(easymotion-F)
map <C-j> <Plug>(easymotion-f)
nnoremap <Leader>w <C-w>
nnoremap <Leader>w\ <C-w>\| <C-w>_
nnoremap <Leader>W :InteractiveWindow<CR>
nnoremap <Leader>o :NERDTreeFocus<CR>
nnoremap <Leader>l :CommandTLine<CR>
set clipboard=unnamed
set nofoldenable
set ignorecase
set smartcase
set cursorline
set wildignore+=*/target/*

python3 import vim

function! LeftWindowOrTab(column)
    " I really have to do this shit to get the position of the current window
    let wincol = py3eval("vim.windows[" . winnr() . " - 1].col")
    if wincol == 0 "leftmost window
        tabp
    else
        wincmd h
    endif
endfunction

function! RightWindowOrTab(column)
    if a:column >= &columns - winwidth(winnr()) "rightmost window
        tabn
    else
        wincmd l
    endif
endfunction

" Prevent accidental bg
noremap <C-z> <ESC>

nnoremap <M-e> <C-w>j
nnoremap <M-i> <C-w>k
nnoremap <silent> <M-n> :call LeftWindowOrTab(screencol())<CR>
nnoremap <silent> <M-o> :call RightWindowOrTab(screencol())<CR>
nnoremap <M-S-e> <C-w>J
nnoremap <M-S-i> <C-w>K
nnoremap <M-S-n> <C-w>H
nnoremap <M-S-o> <C-w>L
nnoremap <M-w> :InteractiveWindow<CR>

let g:pathogen_disabled = []

if !executable('nim')
    call add(g:pathogen_disabled, 'nvim-nim')
endif

nnoremap gd :vs \| NimDefinition<CR>

if !has("nvim")
    call add(g:pathogen_disabled, 'Neomake')
endif

set switchbuf+=usetab,newtab
nmap <c-t> :vs<bar>:b#<CR>

execute pathogen#infect()

if has("nvim")
    call deoplete#enable()
    " use tab to forward cycle
    inoremap <silent><expr><tab>   pumvisible() ? "\<c-n>" : "\<tab>"
    " use tab to backward cycle
    "inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
    set scrollback=100000
endif

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

syntax enable
colorscheme dracula
hi CursorLine ctermbg=black
highlight Identifier ctermfg=255
highlight ErrorMsg ctermfg=231 ctermbg=124
set nofoldenable

set number

let termapp = $TERM_PROGRAM
if termapp=~"iTerm.app"
    let &t_SI = "\<Esc>]1337;CursorShape=1\x7"
    let &t_EI = "\<Esc>]1337;CursorShape=0\x7"
endif

autocmd! BufRead *.nim Neomake
autocmd! BufWritePost *.nim Neomake
autocmd! BufRead *.go Neomake
autocmd! BufWritePost *.go Neomake
"autocmd! BufWritePost *.java Neomake
"let g:nvim_nim_enable_default_binds = 0

let g:EclimCompletionMethod = 'omnifunc'

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
nnoremap <Leader>nd :! nim c --threads:on "-o:$NIMBIN/"`basename "%" .nim` "%"<CR>
nnoremap <Leader>no :NimOutline<CR>

function! JavaAskAndRename()
    let wordUnderCursor = expand("<cword>")
    call inputsave()
    let replacement = input('Rename to: ', wordUnderCursor)
    call inputrestore()
    exec 'JavaRename '.replacement
endfunction
nnoremap <Leader>jr :call JavaAskAndRename()<CR>
nnoremap <Leader>jd :vert JavaSearchContext<CR>
let g:EclimDefaultFileOpenAction = 'vsplit'

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_quiet_messages = { "type": "style" }

au BufNewFile,BufRead *.nim set filetype=nim tabstop=2 shiftwidth=2

au BufNewFile,BufRead *.go set softtabstop=0 noexpandtab

let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['nim'] = ['.']
let g:ycm_auto_trigger = 0
let g:ycm_min_num_identifier_candidate_chars = 2

nnoremap <Leader>t :execute 'Files' fnameescape(getcwd())<CR>

if has('nvim')
    let $VISUAL = 'nvr -cc split --remote-wait'
endif

command! -nargs=* T split | terminal <args>
command! -nargs=* VT vsplit | terminal <args>
command! -nargs=* TSP tab split <args>

cabbr <expr> %% expand('%:p:h')

if has('unix')
    set clipboard+=unnamedplus
endif
let g:syntastic_python_flake8_post_args='--ignore=E501'

" Complete to longest match rather than first full command
set wildmode=longest:full,full

let s:simple = 0
function! ToggleStatusLines()
    if s:simple == 0
        set laststatus=0
        set noruler
        set noshowcmd
        set noshowmode
        let s:hidden=1
    else
        set laststatus=2
        set ruler
        set showcmd
        set showmode
        let s:hidden=0
    endif
endfunction

let g:terminal_scrollback_buffer_size = 100000
let g:SuperTabDefaultCompletionType = "<c-n>"
au TermOpen * setlocal nonumber norelativenumber
autocmd TermOpen * startinsert
