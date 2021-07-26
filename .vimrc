" Here be dragons

autocmd! bufwritepost .vimrc source %

set rtp^=~/.vim/
set rtp+=/usr/local/opt/fzf
let mapleader = "\<Space>"

call plug#begin()
Plug 'https://github.com/natebosch/vim-lsc'
call plug#end()

set hidden
set clipboard=unnamed
set nofoldenable
set ignorecase
set smartcase
set cursorline
set wildignore+=*/target/*
set nomodeline
set gdefault

inoremap yy <ESC>
tnoremap yy <C-\><C-n>
vnoremap <ESC> <C-c>
vnoremap . :norm.<CR>
map <C-k> <Plug>(easymotion-F)
map <C-j> <Plug>(easymotion-f)
nnoremap <Leader>w <C-w>
nnoremap <Leader>l :CommandTLine<CR>
nnoremap <Leader>w\ <C-w>\| <C-w>_
nnoremap <Leader>W :InteractiveWindow<CR>
nnoremap <Leader>o :NERDTreeFocus<CR>
nnoremap <Leader>e :lnext<CR>
nnoremap <Leader>f :NERDTreeFind<CR>
nnoremap <Leader>E :lprevious<CR>
nnoremap <Leader>t :execute 'Files' fnameescape(getcwd())<CR>
nnoremap <Leader>nr :! nim c -r --threads:on --verbosity:0 %<CR>
nnoremap <Leader>ni :! nim c -d:release --threads:on "-o:$NIMBIN/"`basename "%" .nim` "%"<CR>
nnoremap <Leader>nd :! nim c --threads:on "-o:$NIMBIN/"`basename "%" .nim` "%"<CR>
nnoremap <Leader>no :NimOutline<CR>
nnoremap <Leader>gc :GoReferrers<CR>
nnoremap <Leader>jr :call JavaAskAndRename()<CR>
nnoremap <Leader>jd :vert JavaSearchContext<CR>

" COOL
nnoremap <silent> <Leader>y :Multiterm!<CR>
nnoremap <silent> <Leader>1 :1Multiterm!<CR>
nnoremap <silent> <Leader>2 :2Multiterm!<CR>
nnoremap <silent> <Leader>3 :3Multiterm!<CR>

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
nnoremap gd :vs \| NimDefinition<CR>

let g:python3_host_prog = 'python3'

function! LeftWindowOrTab(column)
    let orig = winnr()
    wincmd h
    if orig == winnr()
        tabp
    endif
endfunction

function! RightWindowOrTab(column)
    let orig = winnr()
    wincmd l
    if orig == winnr()
        tabn
    endif
endfunction

function! ToggleNerdTreeAndTagbar()
	" https://github.com/pseewald/nerdtree-tagbar-combined/blob/master/plugin/toggletagbar.vim
    if exists('t:NERDTreeBufName')
        let s:nerdtree_open = bufwinnr(t:NERDTreeBufName) != -1
    else
        let s:nerdtree_open = 0
    endif
    let s:tagbar_open = bufwinnr('__Tagbar__') != -1
	if s:nerdtree_open
		if expand('%') == t:NERDTreeBufName
			NERDTreeClose
			TagbarOpen f
		else
			NERDTreeFocus
		endif
	else
		if expand('%') =~ '__Tagbar__'
			TagbarClose
			NERDTree
		else
			TagbarOpen fj
		endif
    endif
endfunction

function! CloseNerdTreeAndTagbar()
    TagbarClose
    NERDTreeClose
endfunction

nnoremap <Leader>o :call ToggleNerdTreeAndTagbar()<CR>
nnoremap <Leader>O :call CloseNerdTreeAndTagbar()<CR>
let g:tagbar_map_showproto = '<C-Space>'


let g:pathogen_disabled = []

if !executable('nim')
    call add(g:pathogen_disabled, 'nvim-nim')
endif

if !has("nvim")
    call add(g:pathogen_disabled, 'Neomake')
else
    python3 import vim
endif

set switchbuf+=usetab,newtab
nmap <c-t> :vs<bar>:b#<CR>


let g:nvim_nim_enable_default_binds = 0

"let g:lsc_server_commands = {'ava': '/Users/khogeland/git/java-language-server/dist/lang_server_mac.sh'}
let g:lsc_enable_autocomplete  = v:true
let g:lsc_enable_diagnostics = v:true

execute pathogen#infect()

if has("nvim")
    call deoplete#enable()
    " use tab to forward cycle
    inoremap <silent><expr><tab>   pumvisible() ? "\<c-n>" : "\<tab>"
    " use tab to backward cycle
    "inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
    set scrollback=100000
    au TermOpen * setlocal nonumber norelativenumber
endif

autocmd BufNewFile,BufRead BUILD.*   set syntax=bzl

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


function! JavaAskAndRename()
    let wordUnderCursor = expand("<cword>")
    call inputsave()
    let replacement = input('Rename to: ', wordUnderCursor)
    call inputrestore()
    exec 'JavaRename '.replacement
endfunction
let g:EclimDefaultFileOpenAction = 'vsplit'

au BufNewFile,BufRead *.nim set filetype=nim tabstop=2 shiftwidth=2
au BufNewFile,BufRead *.bzl set tabstop=2 shiftwidth=2
au BufNewFile,BufRead BUILD.* set tabstop=2 shiftwidth=2

autocmd! BufRead *.go set softtabstop=0 noexpandtab

let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['nim'] = ['.']
let g:ycm_auto_trigger = 0
let g:ycm_min_num_identifier_candidate_chars = 2


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

highlight LeadingSpace ctermbg=235 guibg=235
match LeadingSpace /\S\@<! /
autocmd BufRead * match LeadingSpace /\S\@<! /
autocmd InsertChange * match LeadingSpace /\S\@<! /
autocmd InsertChange term:* match LeadingSpace /ishouldreadthedocs/

autocmd InsertLeave * pclose!
let g:deoplete#sources#go#fallback_to_source = 1
let $VTE_VERSION="100"

" from https://github.com/fatih/vim-go/issues/1037#issuecomment-346887216
" from https://gist.github.com/tyru/984296
" Substitute a:from => a:to by string.
" To substitute by pattern, use substitute() instead.
function! s:substring(str, from, to)
  if a:str ==# '' || a:from ==# ''
      return a:str
  endif
  let str = a:str
  let idx = stridx(str, a:from)
  while idx !=# -1
      let left  = idx ==# 0 ? '' : str[: idx - 1]
      let right = str[idx + strlen(a:from) :]
      let str = left . a:to . right
      let idx = stridx(str, a:from)
  endwhile
  return str
endfunction

function! s:chomp(string)
  return substitute(a:string, '\n\+$', '', '')
endfunction

function! s:go_guru_scope_from_git_root()
" chomp because get rev-parse returns line with newline at the end
  return s:chomp(s:substring(system("git rev-parse --show-toplevel"),$GOPATH . "/src/","")) . "/..."
endfunction

au FileType go silent exe "GoGuruScope " . s:go_guru_scope_from_git_root()
let g:sneak#label = 1

au FileType haskell nnoremap <buffer> <F1> :HdevtoolsType<CR>
au FileType haskell nnoremap <buffer> <silent> <F2> :HdevtoolsInfo<CR>
au FileType haskell nnoremap <buffer> <silent> <F3> :HdevtoolsClear<CR>
"
" wrap :cnext/:cprevious and :lnext/:lprevious
function! WrapCommand(direction, prefix)
    if a:direction == "up"
        try
            execute a:prefix . "previous"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "last"
        catch /^Vim\%((\a\+)\)\=:E\%(776\|42\):/
        endtry
    elseif a:direction == "down"
        try
            execute a:prefix . "next"
        catch /^Vim\%((\a\+)\)\=:E553/
            execute a:prefix . "first"
        catch /^Vim\%((\a\+)\)\=:E\%(776\|42\):/
        endtry
    endif
endfunction

nnoremap <silent> <Leader>C :call WrapCommand('up', 'c')<CR>
nnoremap <silent> <Leader>c  :call WrapCommand('down', 'c')<CR>

nnoremap <silent> <Leader>E :call WrapCommand('up', 'l')<CR>
nnoremap <silent> <Leader>e  :call WrapCommand('down', 'l')<CR>

let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }

let g:tagbar_left = 1
set splitbelow
let g:gutentags_define_advanced_commands = 1
let g:gutentags_enabled = 0
augroup auto_gutentags
  au FileType python,java,scala,sh,groovy,vim,go let g:gutentags_enabled=1
augroup end
set modelines=0
let g:go_def_reuse_buffer = 1
let g:go_def_mapping_enabled = 0
nmap gd <Plug>(go-def-vertical)
