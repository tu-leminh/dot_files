# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Source Powerlevel10k theme
source ~/dot_files/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme

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
source ~/dot_files/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load zsh-autosuggestions
source ~/dot_files/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load zsh-history-substring-search
source ~/dot_files/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

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