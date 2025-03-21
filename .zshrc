source ~/git/ez-compinit/ez-compinit.plugin.zsh

source ~/.zpath
source ~/.zsh_aliases
source ~/.zlocal

export VISUAL=_nvim_launcher
export EDITOR="$VISUAL"

export SSH_KEY_PATH="~/.ssh/id_my"

export GOPATH=$HOME/go
require go && export PATH="$PATH:$(go env GOPATH)/bin"

export NIMBIN="$HOME/nim/bin"
export PATH="$PATH:$NIMBIN"

export GPG_TTY=$(tty)

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^U" edit-command-line

autoload -U colors && colors

source ~/.zsh_prompt

[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh

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

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

#source ~/.zsh_mpd

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

function daemon {
    $@ &>/dev/null &
}

function note {
    mkdir -p ~/notes
    $EDITOR ~/notes/$@
}
function rmnote {
    rm ~/notes/$1
}

[ -e ~/.ssh/id_my ] && function share {
    ssh_string=`cat ~/.ssh/id_my.pub | cut -f3 -d' '`
    file=$(basename "$1")
    rsyncp "$1" "$ssh_string":"/data/share/${file}"
    url="https://`echo $ssh_string | cut -d'@' -f2`/share/${file}"
    echo $url
    require pbcopy && echo $url | pbcopy
    require xclip && echo $url | xclip -i -selection clipboard
}

function grepl {
    grep --color=always $@ | less -R
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

function randstr {
    cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w ${1:-8} | head -n 1
}

function swapf {
    temp=".$1"`randstr`
    mv "$1" "$temp" && \
    mv "$2" "$1" && \
    mv "$temp" "$2"
}

function mac_startup {
    function setjdk {
        local ver=${1?Usage: setjdk <version>}
        export JAVA_HOME=$(/usr/libexec/java_home -v $ver)
        PATH=$(echo $PATH | tr ':' '\n' | grep -v Java | tr '\n' ':')
        export PATH=$JAVA_HOME/bin:$PATH
    }
    test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
}

function linux_startup {}

case "$OSTYPE" in
  darwin*); mac_startup;;
  linux*); linux_startup;;
esac
unset -f mac_startup
unset -f linux_startup

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -e ~/.zsh_fzf ] || fzf --zsh > ~/.zsh_fzf
source ~/.zsh_fzf

bindkey '^R' history-incremental-search-backward
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

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

source ~/.zsh_git
