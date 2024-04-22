setopt hist_ignore_all_dups inc_append_history
HISTFILE=${ZDOTDIR}/.zhistory
HISTSIZE=4096
SAVEHIST=4096

export ERL_AFLAGS="-kernel shell_history enabled"
