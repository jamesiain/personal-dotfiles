setopt prompt_subst     # enable command substition in prompt

zle_highlight=(default:fg=cyan)     # greater visibility for typed commands

running_in_docker() {
    if [[ ${OSTYPE} = 'linux'* ]]; then
        (awk -F/ '$2 == "docker"' /proc/self/cgroup | read non_empty_input)
    else
        false
    fi
}

precmd() {
    EXIT_CODE=$?
    if [[ $EXIT_CODE == 0 ]]; then
        PREV_EXIT=0
    elif [[ $EXIT_CODE != $PREV_EXIT ]]; then
        print -P -u2 "%F{red}Exit code: %B$EXIT_CODE%b%f"
        PREV_EXIT=$EXIT_CODE
    fi
    echo   # print a blank line before each entry in the command history
}

zmodload zsh/datetime
function zle-line-init zle-keymap-select zle-line-pre-redraw {
    PROMPT=""
    RPROMPT=""

    if [[ $ACCEPT_LINE == "blankline" ]]; then
        # PROMPT+="%F{yellow}    ···%f"
        # RPROMPT+="%F{yellow}···    %f"
    elif [[ $ACCEPT_LINE == "timestamp" ]]; then
        PROMPT+="%F{magenta}%D{%F %T}%f %# "
    else
        running_in_docker && \
            PROMPT+="%F{blue}%B[ %b%f"

        if [[ -n $SSH_CONNECTION ]]; then
            LOCAL_COLOR="magenta"
        else
            LOCAL_COLOR="green"
        fi

        ZSH_THEME_VIRTUALENV_PREFIX="%F{cyan}["
        ZSH_THEME_VIRTUALENV_SUFFIX="]%f "

        PROMPT+="\$(virtualenv_prompt_info)"
        PROMPT+="%F{%(!.red.blue)}%n%f"
        PROMPT+="%F{cyan}@%f%F{${LOCAL_COLOR}}%m%f %F{yellow}%3~%f %# "

        if [[ "$KEYMAP" == vicmd ]]; then
            local VISUAL_MODE="%{$fg[black]%} %{$bg[cyan]%} VISUAL %{$reset_color%}"
            local NORMAL_MODE="%{$fg[black]%} %{$bg[yellow]%} NORMAL %{$reset_color%}"

            if (( REGION_ACTIVE )); then
                VI_MODE="$VISUAL_MODE"
            else
                VI_MODE="$NORMAL_MODE"
            fi
        else
            VI_MODE=""
        fi

        RPROMPT+="${VI_MODE} ${GITSTATUS_PROMPT}$(svn_prompt_info)"

        running_in_docker && \
            RPROMPT+="%F{blue}%B ]%b%f"
    fi

    ACCEPT_LINE=""
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-pre-redraw

ACCEPT_LINE=""
function change-prompt-on-accept-line {
    if [[ -z $BUFFER ]]; then
        ACCEPT_LINE="blankline"
    else
        ACCEPT_LINE="timestamp"
    fi

    zle accept-line
}

zle -N change-prompt-on-accept-line
bindkey -M viins "^M" change-prompt-on-accept-line
bindkey -M vicmd "^M" change-prompt-on-accept-line
