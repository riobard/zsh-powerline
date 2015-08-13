readonly GIT_BRANCH_SYMBOL='⑂ '
readonly GIT_BRANCH_CHANGED_SYMBOL='+'
readonly GIT_NEED_PUSH_SYMBOL='⇡'
readonly GIT_NEED_PULL_SYMBOL='⇣'

readonly PS_SYMBOL_DARWIN=''
readonly PS_SYMBOL_LINUX='$'
readonly PS_SYMBOL_OTHER='%'

# Assign prompt symbol based on OS
case "$(uname)" in
    Darwin)
        readonly PS_SYMBOL=$PS_SYMBOL_DARWIN
        ;;
    Linux)
        readonly PS_SYMBOL=$PS_SYMBOL_LINUX
        ;;
    *)
        readonly PS_SYMBOL=$PS_SYMBOL_OTHER
        ;;
esac

__git_info() {
    [ -x "$(which git)" ] || return    # git not found

    # get current branch name or short SHA1 hash for detached head
    local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
    [ -n "$branch" ] || return  # git branch not found

    local marks

    # branch is modified?
    [ -n "$(git status --porcelain)" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL"

    # how many commits local branch is ahead/behind of remote?
    local stat="$(git status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
    local aheadN="$(echo $stat | grep -o 'ahead \d\+' | grep -o '\d\+')"
    local behindN="$(echo $stat | grep -o 'behind \d\+' | grep -o '\d\+')"
    [ -n "$aheadN" ] && marks+=" $GIT_NEED_PUSH_SYMBOL$aheadN"
    [ -n "$behindN" ] && marks+=" $GIT_NEED_PULL_SYMBOL$behindN"

    # print the git branch segment without a trailing newline
    printf " $GIT_BRANCH_SYMBOL$branch$marks "
}


__config_prompt() {
    # Color coding based on exit code of the previous command.  Note this must
    # be dealt with in the beginning of the function, otherwise the $? will not
    # match the right command executed.
    if [ $? -eq 0 ]
    then
        local EXIT="%{$bg[green]%}"
    else
        local EXIT="%{$bg[red]%}"
    fi

    local RESET="%{${reset_color}%}"
    local SYMBOL="%{$fg[white]%}$EXIT $PS_SYMBOL $RESET"
    local GIT="%{$bg[blue]%}%{$fg[white]%}$(__git_info)$RESET"
    local PATH="%{$bg[black]%}%{$fg[white]%} %~ $RESET"
    local TIME="%{$fg[green]%}$(/bin/date -u '+%Y-%m-%d %H:%M:%S')$RESET"

    PROMPT="$PATH$GIT$SYMBOL "
    RPROMPT="$TIME"
}

precmd() {
    __config_prompt
}

preexec() {
}

