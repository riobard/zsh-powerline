readonly GIT_BRANCH_SYMBOL='⑂'
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
    hash git 2>/dev/null || return    # git not found

    # get current branch name or short SHA1 hash for detached head
    local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
    [ -n "$branch" ] || return  # git branch not found

    local marks

    # scan first two lines of output from `git status`
    while IFS= read -r line; do
        if [[ $line =~ ^## ]]; then # header line
            [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $GIT_NEED_PUSH_SYMBOL$match[1]"
            [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $GIT_NEED_PULL_SYMBOL$match[1]"
        else # branch is modified if output contains more lines after the header line
            marks=" $GIT_BRANCH_CHANGED_SYMBOL$marks"
            break
        fi
    done < <(git status --porcelain --branch)  # note the space between the two <

    # print the git branch segment without a trailing newline
    printf " $GIT_BRANCH_SYMBOL$branch$marks"
}


__config_prompt() {
    # Color coding based on exit code of the previous command.  Note this must
    # be dealt with in the beginning of the function, otherwise the $? will not
    # match the right command executed.

    if [ $? -eq 0 ]; then
        local symbol_color='green'
    else
        local symbol_color='red'
    fi

    local cwd="%F{blue}%~%f"
    local git="%F{cyan}$(__git_info)%f"
    local symbol="%F{$symbol_color}$PS_SYMBOL%f"
    local time="%F{cyan}%D{%H:%M:%S}%f"

    PROMPT="$cwd$git $symbol "
    RPROMPT="$time"
}

precmd() {
    __config_prompt
}

preexec() {
}

