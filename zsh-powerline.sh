# Colorscheme
readonly COLOR_CWD='blue'
readonly COLOR_GIT='cyan'
readonly COLOR_SUCCESS='green'
readonly COLOR_FAILURE='red'
readonly COLOR_TIME='cyan'

readonly GIT_SYMBOL_BRANCH='⑂'
readonly GIT_SYMBOL_BRANCH_CHANGED='*'
readonly GIT_SYMBOL_PUSH='↑'
readonly GIT_SYMBOL_PULL='↓'

# Assign prompt symbol based on OS
case "$(uname)" in
    Darwin)
        readonly PS_SYMBOL=''
        ;;
    Linux)
        readonly PS_SYMBOL='$'
        ;;
    *)
        readonly PS_SYMBOL='%'
        ;;
esac


_git_info() {
    hash git 2>/dev/null || return    # git not found

    # get current branch name or short SHA1 hash for detached head
    local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
    [ -n "$branch" ] || return  # git branch not found

    local marks

    # scan first two lines of output from `git status`
    while IFS= read -r line; do
        if [[ $line =~ ^## ]]; then # header line
            [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $GIT_SYMBOL_PUSH$match[1]"
            [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $GIT_SYMBOL_PULL$match[1]"
        else # branch is modified if output contains more lines after the header line
            marks="$GIT_SYMBOL_BRANCH_CHANGED$marks"
            break
        fi
    done < <(git status --porcelain --branch)  # note the space between the two <

    # print the git branch segment without a trailing newline
    printf " $GIT_SYMBOL_BRANCH$branch$marks"
}


_config_prompt() {
    # Color coding based on exit code of the previous command.  Note this must
    # be dealt with in the beginning of the function, otherwise the $? will not
    # match the right command executed.

    if [ $? -eq 0 ]; then
        local symbol="%F{$COLOR_SUCCESS}$PS_SYMBOL%f"
    else
        local symbol="%F{$COLOR_FAILURE}$PS_SYMBOL%f"
    fi

    local cwd="%F{$COLOR_CWD}%~%f"
    local git="%F{$COLOR_GIT}$(_git_info)%f"
    local time="%F{$COLOR_TIME}%D{%H:%M:%S}%f"

    PROMPT="$cwd$git $symbol "
    RPROMPT="$time"
}


# useful zsh hook functions

precmd() {  # run before each prompt
    _config_prompt
}


preexec() { # run after user command is read and about to execute
}


chpwd() { # run when changing current working directory
}
