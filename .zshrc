# Messy ol' PATH
export PATH="$HOME/bin:/opt/wine-staging/bin:/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/python2.7/site-packages:/usr/local/share/npm/bin:/usr/local/heroku/bin:/Library/Frameworks/Python.framework/Versions/3.4/bin:$HOME/Library/Android/sdk/platform-tools"

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

function require {
    rc=0
    silent=true
    if [ "$1" = "-v" ]; then 
        silent=false
        shift
    fi
    for req in $@; do
        type "$req" 2>&1 >/dev/null || {
            rc=1
            $silent || echo "Cannot find \"$req\" in path"
        }
    done
    return $rc
}
###########################################

export EDITOR=vim
export SSH_KEY_PATH="~/.ssh/id_my"

# Private config (credentials etc.)
if [ -e ~/.zprivate/key ]; then
    openssl bf -d -kfile ~/.zprivate/key -in ~/.zprivate/rc.enc | source /dev/stdin
fi

# Aliases
source ~/.zsh_aliases

### oh-my-zsh ###
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
#DISABLE_AUTO_UPDATE="true"
plugins=(git apache2-macports autojump bower dircycle history pip python sudo web-search colorize cp jvm alias-tips)
source $ZSH/oh-my-zsh.sh
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^Y" edit-command-line
#################


### Let's git dirty ###

function _git_fetch_origin() {
    if [ ! -e '.git' ]; then
        return 0
    else
        ({
            GIT_TERMINAL_PROMPT=0 git fetch origin master >/dev/null 2>&1
            touch .git/.last-origin-fetch
        } &)
    fi
}

function git_commits_ahead_master() {
    if $(command git rev-parse --git-dir > /dev/null 2>&1)
    then
        local COMMITS="$(git rev-list --count origin/master..HEAD)"
        echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$COMMITS$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
    fi
}

function git_commits_behind_master() {
    if $(command git rev-parse --git-dir > /dev/null 2>&1)
    then
        echo $(git rev-list --count HEAD..origin/master)
    fi
}

function _git_behind_master_prompt() {
    BEHIND=${$(git_commits_behind_master 2>/dev/null):-0}
    if [ $BEHIND -gt 0 ]; then
        echo -n "%{$fg_bold[red]%}$BEHIND%{$fg_bold[blue]%}:%{$fg_bold[red]%}"
    fi
}

function _git_ahead_master_prompt() {
    AHEAD=${$(git_commits_ahead_master 2>/dev/null):-0}
    if [ $AHEAD -gt 0 ]; then
        echo -n "%{$fg_bold[blue]%}:%{$fg_bold[red]%}$AHEAD"
    fi
}

# git info prompt that shows commits head and behind master
function much_git_prompt_info() {
    local ref
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]
    then
        ref=$(command git symbolic-ref HEAD 2> /dev/null)  || ref=$(command git rev-parse --short HEAD 2> /dev/null)  || return 0
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(_git_behind_master_prompt)${ref#refs/heads/}$(_git_ahead_master_prompt)$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
}

### Prompt ###
export ret_status=
setopt PROMPT_SUBST
export ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
export PROMPT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(much_git_prompt_info)'
export PERIOD=15
autoload -Uz add-zsh-hook
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

# git-fetch every minute if possible
add-zsh-hook periodic _git_fetch_origin
PROMPT_SSH_PREFIX="[`hostname -s`] "
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    export PROMPT="$PROMPT_SSH_PREFIX$PROMPT"
fi
##############

### Python ###
alias python=python3
alias pip=pip3
##############

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

function random-str {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-8} | head -n 1
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
    setjdk 1.8
}

function linux_startup {
    export ret_status="%(?:%{$fg_bold[green]%}▶ :%{$fg_bold[red]%}▶ )"
}

case "$OSTYPE" in
  darwin*); mac_startup;;
  linux*); linux_startup;;
esac
unset -f mac_startup
unset -f linux_startup

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Machine-specific config
[ -e ~/.zlocal ] && source ~/.zlocal

