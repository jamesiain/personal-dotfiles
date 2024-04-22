if type brew &>/dev/null; then

    # Activate zsh-autosuggestions
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    bindkey "^ " forward-word
fi

