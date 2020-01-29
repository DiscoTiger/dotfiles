setopt histignorealldups
setopt interactivecomments
setopt menucomplete
setopt promptsubst
setopt sharehistory
setopt no_nomatch
setopt no_nullglob

export KEYTIMEOUT=1
export VISUAL=code
export EDITOR=code
export ZSH=/usr/share/oh-my-zsh

# Muh Aliases
alias ls='ls --color=auto'
alias mkcd='_() { mkdir $1; cd $1; }; _'
alias 'cd..'='cd ..'
alias reload='source ~/.zshrc'
alias cz='vim ~/.zshrc'
alias ci3='vim ~/.config/i3/config'
alias p='sudo pacman'
alias vi='vim'

print_prompt_git_info() {
    BRANCH_OR_TAG="$(git symbolic-ref --short HEAD 2> /dev/null || \
        git describe --exact-match HEAD 2> /dev/null)"

    if [ -n "$BRANCH_OR_TAG" ]; then
        echo -n "%B%F{magenta}$BRANCH_OR_TAG%f%b" # Print working branch or tag
        CHANGES="$(git status --porcelain | wc -l)"

        if [ "$CHANGES" -ne "0" ]; then
            echo -n "%B%F{yellow}*%f%b" # Indicator for uncommitted changes
        fi

        echo -n " "
    fi
}

print_prompt_symbol() {
    # Set prompt arrow color based on the exit code returned by the last command
    # that was ran in the shell
    if [ "$1" -eq "0" ]; then
        echo -n "%B%F{green}"
    else
        echo -n "%B%F{red}"
    fi

    echo -n "➜ %f%b"
}

print_prompt() {
    EXIT_CODE="$?" # Save last command's exit code
    echo -n "%B%F{cyan}%~%f%b " # Print working directory
    print_prompt_git_info
    print_prompt_symbol "$EXIT_CODE"
}

PROMPT='$(print_prompt)'

precmd() {
    RPROMPT=''
}

# Change cursor to pipe in insert and block in normal mode
function zle-line-init {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] ||
       [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] ||
	 [[ ${KEYMAP} == viins ]] ||
	 [[ ${KEYMAP} = '' ]] ||
	 [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' }

# Keybindings
bindkey -v # Enable Vi emulation
bindkey "^[[2~"   overwrite-mode                    # Insert key
bindkey "^[[H"    beginning-of-line                 # Home key
bindkey "^[[5~"   up-line-or-history                # Page Up key
bindkey "^[[3~"   delete-char                       # Delete key
bindkey "^[[F"    end-of-line                       # End key
bindkey "^[[6~"   down-line-or-history              # Page Down key
bindkey "^[[A"    history-beginning-search-backward # Up arrow key
bindkey "^[[B"    history-beginning-search-forward  # Down arrow key
bindkey "^[[1;5C" forward-word                      # Ctrl + left arrow key
bindkey "^[[1;5D" backward-word                     # Ctrl + right arrow key

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' format '%B%F{blue}Completing %d%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' menu select=5
zstyle ":completion:*:descriptions" format "%B%d%b"
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt '%B%F{blue}At %p: Hit TAB for more, or the character to insert%b%f'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt '%B%F{blue}Scrolling active: current selection at %p%b%f'
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Use vim keys in tab complete menu
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "j" vi-forward-char
bindkey -M menuselect "l" vi-down-line-or-history

# thefuck
eval $(thefuck --alias)

source $ZSH/plugins/zsh-completions/zsh-completions.plugin.zsh
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$HOME/.cargo/bin:$PATH"

