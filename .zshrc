## Functions for command prerequisites ### 
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
openssl bf -d -kfile ~/.zprivate/key -in ~/.zprivate/rc.enc | source /dev/stdin

# Aliases
source ~/.zsh_aliases

### oh-my-zsh ###
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
#DISABLE_AUTO_UPDATE="true"
plugins=(git apache2-macports autojump bower dircycle history pip python sudo web-search colorize cp jvm alias-tips)
source $ZSH/oh-my-zsh.sh
export ret_status="%(?:%{$fg_bold[green]%}▶ :%{$fg_bold[red]%}▶ )"
#################

### SSH prompt ###
PROMPT_SSH_PREFIX='[xub] '
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    export PROMPT="$PROMPT_SSH_PREFIX$PROMPT"
fi
##################

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
DEER_KEYS[up]=w
DEER_KEYS[page_up]=W
DEER_KEYS[down]=s
DEER_KEYS[page_down]=S
DEER_KEYS[enter]=d
DEER_KEYS[leave]=a
############

# Messy ol' PATH
export PATH="/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/python2.7/site-packages:/usr/local/share/npm/bin:/usr/local/heroku/bin:/Library/Frameworks/Python.framework/Versions/3.4/bin:$HOME/Library/Android/sdk/platform-tools"

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

function music {
    require -v mpd run-one mpdas ncmpcpp || return 1
	mpd
    run-one mpdas -d
	ncmpcpp
}

function define {
    require_envs MASHAPE_KEY || return 1
    require -v jq curl || return 1
	curl -s https://wordsapiv1.p.mashape.com/words/$@/definitions \
	-H "X-Mashape-Key: $MASHAPE_KEY" | jq '.definitions[].definition' | cat -n
}

function mac_startup {
	plugins+=(osx bwana)
	require trash && alias rm=trash
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
    export ret_status=
}

function linux_startup {
	# nothing at all
}

case "$OSTYPE" in
  darwin*); mac_startup;;
  linux*); linux_startup;;
esac
unset -f mac_startup
unset -f linux_startup

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
