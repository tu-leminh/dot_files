# Check if we're running zsh (but allow sourcing in bash for testing)
if [[ ! -n "$ZSH_VERSION" ]] && [[ "$0" != "-zsh" ]] && [[ "$0" != "zsh" ]]; then
  # This is a simple check - we'll be more permissive when sourcing
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # We're running the script directly, not sourcing it
    echo "This script is intended for Zsh. Please run 'zsh' to switch to Zsh shell."
    return 2>/dev/null || exit 1
  fi
fi

# Enable autocompletion and required ZSH modules before initializing Oh My Posh
autoload -Uz compinit zsh/parameter
compinit

# Initialize Oh My Posh
if [[ -f ~/.local/bin/oh-my-posh ]]; then
  eval "$(~/.local/bin/oh-my-posh init zsh --config ~/dot_files/zsh/oh-my-posh-config.json)"
fi

# Enable autocompletion
autoload -Uz compinit
compinit

# Enable colors and completion styling
zstyle ':completion:*' menu select
zmodload zsh/complist

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Change cursor shape for different vi modes.
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
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Load zsh-syntax-highlighting
if [[ -f ~/dot_files/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/dot_files/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Load zsh-autosuggestions
if [[ -f ~/dot_files/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/dot_files/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-history-substring-search
if [[ -f ~/dot_files/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source ~/dot_files/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# Bind UP and DOWN arrow keys for history search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# History configuration
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt incappendhistory
setopt sharehistory

# Better history search with PageUp and PageDown
bindkey '^[[5~' history-beginning-search-backward
bindkey '^[[6~' history-beginning-search-forward

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Enable fuzzy search with fzf if available
if command -v fzf &> /dev/null; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
  source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
fi

# Auto CD to directories without typing cd
setopt autocd

# Correct typos in command names
setopt correct

# Custom keybindings
# Ctrl+Space to accept autosuggestion
bindkey '^ ' autosuggest-accept

# Export terminal color settings for tmux and Neovim
export TERM="xterm-256color"

# Auto-start tmux when connecting via SSH
if [[ -n "$SSH_CONNECTION" ]]; then
    if command -v tmux >/dev/null 2>&1; then
        if [[ -z "$TMUX" ]]; then
            tmux attach-session -t ssh_tmux 2>/dev/null || tmux new-session -s ssh_tmux
        fi
    fi
fi