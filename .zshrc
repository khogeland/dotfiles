# Messy ol' PATH
export PATH="$HOME/bin:/usr/local/opt/ruby/bin:/opt/wine-staging/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/grep/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/python2.7/site-packages:/usr/local/share/npm/bin:/usr/local/heroku/bin:/Library/Frameworks/Python.framework/Versions/3.4/bin:$HOME/Library/Android/sdk/platform-tools:$HOME/.nimble/bin:$HOME/Nim/bin:$HOME/.local/bin:$HOME/.cabal/bin:$HOME/.gem/ruby/3.0.0/bin:$HOME/.home_venv/bin"

# Functions for command prerequisites ### 
function require_envs {
    rc=0
    for arg in $@; do
        tvalue=
        if eval "tvalue=\"\$$arg\"" && [ -z "${tvalue}" ]; then
            echo "Missing required variable \"$arg\""
            rc=1
        fi
    done
    return $rc
}

###########################################

[ -e /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

export VISUAL=_nvim_launcher
export EDITOR="$VISUAL"
alias v="$EDITOR"
alias vi="$EDITOR"
alias vim="$EDITOR"
alias nvim="$EDITOR"

export SSH_KEY_PATH="~/.ssh/id_my"

# Private config (credentials etc.)
if [ -e ~/.zprivate/key ]; then
    openssl bf -d -md md5 -kfile ~/.zprivate/key -in ~/.zprivate/rc.enc | source /dev/stdin
fi

# Aliases
source ~/.zsh_aliases

### oh-my-zsh ###
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="true"
plugins=(git apache2-macports autojump bower dircycle colorize)
source $ZSH/oh-my-zsh.sh
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^U" edit-command-line
#################


### Let's git dirty ###

function _git_fetch_origin() {
    if [[ ! -e '.git' || ! -d '.git' ]]; then
        return 0
    else
        ({
            GIT_TERMINAL_PROMPT=0 git fetch origin master 2>/dev/null
            touch .git/.last-origin-fetch
        } &)
    fi
}

function git_commits_ahead_master() {
    if $(command git rev-parse --git-dir > /dev/null 2>&1)
    then
        local COMMITS="$(git rev-list --count origin/master..HEAD)" 2>/dev/null
        echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$COMMITS$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
    fi
}

function git_commits_behind_master() {
    if $(command git rev-parse --git-dir > /dev/null 2>&1)
    then
        echo $(git rev-list --count HEAD..origin/master) 2>/dev/null
    fi
}

export GIT_COLOR_DIRTY="%{$fg[red]%}"
export GIT_COLOR_CLEAN="%{$fg[cyan]%}"

function _git_color() {
    if git diff-index --quiet HEAD -- >/dev/null 2>&1; then
        echo -n "$GIT_COLOR_CLEAN"
    else
        echo -n "$GIT_COLOR_DIRTY"
    fi
}

# git info prompt that shows commits head and behind master
function much_git_prompt_info() {
    local ref
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]
    then
        ref=$(command git symbolic-ref HEAD 2> /dev/null)  || ref=$(command git rev-parse --short HEAD 2> /dev/null)  || return 0
        color_one="$(_git_color)"
        color_two="%{$reset_color%}%{$fg[green]%}"
        BEHIND=${$(git_commits_behind_master 2>/dev/null):-0}
        BEHIND_PROMPT=
        if [ $BEHIND -gt 0 ]; then
            BEHIND_PROMPT="${GIT_COLOR_DIRTY}$BEHIND${color_two}:"
        fi
        AHEAD=${$(git_commits_ahead_master 2>/dev/null):-0}
        AHEAD_PROMPT=
        if [ $AHEAD -gt 0 ]; then
            AHEAD_PROMPT="${color_two}:${color_one}$AHEAD"
        fi
        echo "${color_two}(${color_one}${BEHIND_PROMPT}${color_one}${ref#refs/heads/}${AHEAD_PROMPT}${color_two})%{$reset_color%}"
    fi
}
### Prompt ###
setopt PROMPT_SUBST
export status_dollar="%(?:%{$fg[magenta]%}$:%{$fg[red]%}$)%{$reset_color%}"
export ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}(%{$fg[red]%}"
export PROMPT='%{$fg[yellow]%}%c%{$reset_color%} ${status_dollar} '

export PERIOD=15
autoload -Uz add-zsh-hook

# git-fetch every minute if possible
add-zsh-hook periodic _git_fetch_origin
PROMPT_SSH_PREFIX="[`hostname -s`] "
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    export PROMPT="$PROMPT_SSH_PREFIX$PROMPT"
fi

if [ "$COPY_MODE" ]; then
    export PROMPT="$ "
fi

function rprompt_cmd {
    if [ ! "$COPY_MODE" ]; then
        much_git_prompt_info
    fi
}

############## <copied stuff>
# Thanks to Anish Athalye for the very useful code below!
#
#**Copyright (c) 2013-2015 Anish Athalye (me@anishathalye.com)**

#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
#of the Software, and to permit persons to whom the Software is furnished to do
#so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

RPROMPT=''

ASYNC_PROC=0
function precmd() {
    function async() {
        # save to temp file
        printf "%s" "$(rprompt_cmd)" > "/tmp/zsh_prompt_$$"

        # signal parent
        kill -s USR1 $$
    }

    # do not clear RPROMPT, let it persist

    # kill child if necessary
    if [[ "${ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # start background computation
    async &!
    ASYNC_PROC=$!
}

function TRAPUSR1() {
    # read from temp file
    RPROMPT="$(cat /tmp/zsh_prompt_$$)"

    # reset proc number
    ASYNC_PROC=0

    # redisplay
    zle && zle reset-prompt
}

############## </copied stuff>

### Cursor ###

zle-keymap-select () {
    if [ "$TERM" = "xterm-256color" ]; then
        if [ $KEYMAP = vicmd ]; then
            # the command mode for vi
            echo -ne "\e[2 q"
        else
            # the insert mode for vi
            echo -ne "\e[4 q"
        fi
    fi
}

#############

### Go ###
export GOPATH=$HOME/go
require go && export PATH="$PATH:$(go env GOPATH)/bin"
##########

### Deer ###
source ~/.zsh/deer/deer
zle -N deer-launch
bindkey '^k' deer-launch
alias rifle=open
typeset -Ag DEER_KEYS
DEER_KEYS[up]=i
DEER_KEYS[page_up]=I
DEER_KEYS[down]=e
DEER_KEYS[page_down]=E
DEER_KEYS[enter]=o
DEER_KEYS[leave]=n
############

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

### Process utility ###

function tag_proc {
    PID=$1
    shift
    ps -p "$PID" 2>&1 >/dev/null
    if [ $? -ne 0 ]; then
        echo "Process $PID is not running."
        return 1
    fi
    for tag; do
        TAGDIR="$HOME/.proc/tag/$tag"
        mkdir -p "$TAGDIR"
        touch "$TAGDIR/$PID"
    done
}

function get_tagged_procs { 
    TAG=$1
    TAGDIR="$HOME/.proc/tag/$TAG"
    if [ ! -e "$TAGDIR" ]; then
        echo "Tag $TAG does not exist."
        return 1
    fi
    for pidfile in `find $TAGDIR -type f`; do
        pid=$(basename "$pidfile")
        ps -p "$pid" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            rm -f "$pidfile"
            continue
        fi
        echo $pid
    done
}

### Music ###

function music {
    require -v mpd run-one mpdas ncmpcpp || return 1
    mpd
    run-one mpdas -d
    ncmpcpp
}

function mpstart {
    require_envs MPD_STREAM_ADDRESS || return 1
    require -v mplayer || return 1
    touch ~/.mpslck
    _loop_mplayer >/dev/null 2>&1 & disown
}

function mpstop {
    rm -f ~/.mpslck
    pids=`get_tagged_procs mpd_processes`
    [ $? ] && [ "$pids" != "" ] && echo $pids | xargs kill
}

function _loop_mplayer {
    while [ -e ~/.mpslck ]; do
        mplayer -noconsolecontrols -msglevel all=-1 -ao coreaudio $MPD_STREAM_ADDRESS -loop 0 &
        tag_proc $! mpd_processes
        get_tagged_procs mpd_processes >/dev/null
        sleep 1
        wait
    done
}

##############

### Nim ###

export NIMBIN="$HOME/nim/bin"
export PATH="$PATH:$NIMBIN"

###########

### Misc ###

export GPG_TTY=$(tty)

function untgz {
    file="$1"
    contents=$(tar -tf "$file")
    size=$(wc -l)<<<"$contents"
    if [ $(grep -Pc '^[^(?<=\\)/]+/' <<<"$contents") = $size ]; then
        tar -xzvf "$file"
    else
        filename=$(basename "$file")
        dirname=$(grep -oP ".+(?=\\.tar\\.gz|\\.tgz)") <<<"$filename"
        mkdir "$dirname" && tar -C "$dirname" -xzvf "$file"
    fi
}

unzd() {
    if [[ $# != 1 ]]; then echo I need a single argument, the name of the archive to extract; return 1; fi
    target="${1%.zip}"
    unzip "$1" -d "${target##*/}"
}

function recsh {
    script -q -c "COPY_MODE=true $SHELL -i" /tmp/recsh
    # holy shit
    # the python part is probably possible to replace with a recursive regex, but... no thanks
    tail -n +2 /tmp/recsh | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | python -c "import re; import sys; t = lambda l1: (lambda l2: l1 if l1 == l2 else t(l2))(re.sub('($|[^\b])\b','',l1)); print(t(sys.stdin.read()), end='')" | col -b | eval copy
    #rm /tmp/recsh
}

function daemon {
    $@ &>/dev/null &
}

mkdir -p ~/notes

function note {
    $EDITOR ~/notes/$@
}

function rmnote {
    rm ~/notes/$1
}

compdef "_files -W ~/notes" note
compdef "_files -W ~/notes" rmnote

function recsh {
    script -q -c "COPY_MODE=true $SHELL -i" /dev/fd/3 3>/tmp/recsh
    tail -n +2 /tmp/recsh | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b | copy
}

function share {
    require_envs FILE_SERVER_HOST FILE_SERVER_USER FILE_SERVER_PATH FILE_SERVER_URL || return 1
    ssh_string="$FILE_SERVER_USER@$FILE_SERVER_HOST"
    file=$(basename "$1")
    if [ $2 ] && [ $2 == ${2%/} ]; then
        full=${2#/}
        dirs=$(dirname "$full")
    else
        dirs=${2#/}
        full=${dirs}${file}
    fi
    ssh "$ssh_string" mkdir -p "$FILE_SERVER_PATH"${dirs}
    res=$(rsync -r "$1" "$ssh_string":"$FILE_SERVER_PATH"$full)
    if [ $? != 0 ]; then
        echo $res
    else
        url="$FILE_SERVER_URL"$full
        echo $url
        require pbcopy && echo $url | pbcopy
        require xclip && echo $url | xclip -i -selection clipboard
    fi
}

function grepl {
    grep --color=always $@ | less -R
}

function random-str {
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w ${1:-8} | head -n 1
}

export _SCRATCH_DIR="$HOME/.scratch"
export _SCRATCH=false
export _SCRATCH_BEFORE_DIR="$PWD"

function scratch {
    if [[ $_SCRATCH != true ]]; then
        if [[ -a "$_SCRATCH_DIR" ]]; then
            rm -rf "$_SCRATCH_DIR"
        fi
        mkdir "$_SCRATCH_DIR"
        export _SCRATCH=true
    fi
    test "${PWD##$_SCRATCH_DIR}" != "${PWD}" || {
        export _SCRATCH_BEFORE_DIR="$PWD"
    }
    cd "$_SCRATCH_DIR"
}

function unscratch {
    cd "$_SCRATCH_BEFORE_DIR" || cd ~
    rm -rf "$_SCRATCH_DIR"
    export _SCRATCH=false
}

function swapf {
    temp=".$1"`random-str`
    mv "$1" "$temp" && \
    mv "$2" "$1" && \
    mv "$temp" "$2"
}

function pcol {
    awk '{print $'"$1"'}'
}

function define {
    require_envs MASHAPE_KEY || return 1
    require -v jq curl || return 1
    curl -s https://wordsapiv1.p.mashape.com/words/$@/definitions \
    -H "X-Mashape-Key: $MASHAPE_KEY" | jq '.definitions[].definition' | cat -n
}

function mac_startup {
    plugins+=(osx bwana)
    function copy {
        $@ | pbcopy
    }
    function setjdk {
        local ver=${1?Usage: setjdk <version>}
        export JAVA_HOME=$(/usr/libexec/java_home -v $ver)
        PATH=$(echo $PATH | tr ':' '\n' | grep -v Java | tr '\n' ':')
        export PATH=$JAVA_HOME/bin:$PATH
    }
    #export CURL_CA_BUNDLE=/usr/local/etc/openssl/cert.pem
    alias copy="pbcopy"
}

function linux_startup {
    alias copy="xclip -selection c"
    [[ -s /usr/share/autojump/autojump.zsh ]] && . /usr/share/autojump/autojump.zsh
}

case "$OSTYPE" in
  darwin*); mac_startup;;
  linux*); linux_startup;;
esac
unset -f mac_startup
unset -f linux_startup

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# https://github.com/junegunn/fzf/issues/809
[ -n "$NVIM_LISTEN_ADDRESS" ] && export FZF_DEFAULT_OPTS='--no-height'
bindkey '^R' history-incremental-search-backward
#bindkey '^[^R' fzf-history-widget

setopt extended_glob

neovim_autocd() {
    [[ $NVIM_LISTEN_ADDRESS ]] && (
        if [ -z "$1" ]; then
            ( neovim-autocd.py $$ & )
        else
            ( neovim-autocd.py $$ "$1" & )
        fi
    )
}
chpwd_functions+=( neovim_autocd )
preexec_functions+=( neovim_autocd )

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'

VIRTUAL_ENV_DISABLE_PROMPT=1 source $HOME/.home_venv/bin/activate

[ -e ~/.zlocal ] && source ~/.zlocal
