# Function to check if we're in a ZSH environment
is_zsh() {
  # Check if we're in ZSH by checking the shell name
  [[ "$0" = *zsh* ]] || [[ -n "$ZSH_VERSION" ]]
}

# Function to initialize ZSH-specific features
init_zsh_features() {
  # Enable autocompletion and required ZSH modules before initializing Oh My Posh
  if autoload -Uz compinit zsh/parameter 2>/dev/null; then
    # Initialize completion system with error handling
    if ! compinit 2>/dev/null; then
      echo "Warning: Failed to initialize ZSH completion system"
    fi
  else
    echo "Warning: Failed to load ZSH modules. Some features may not work correctly."
  fi
  
  # Enable colors and completion styling
  if zmodload zsh/complist 2>/dev/null; then
    zstyle ':completion:*' menu select
  else
    echo "Warning: Failed to load zsh/complist module"
  fi
  
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
    if ! source ~/dot_files/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; then
      echo "Warning: Failed to load zsh-syntax-highlighting"
    fi
  fi

  # Load zsh-autosuggestions
  if [[ -f ~/dot_files/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    if ! source ~/dot_files/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; then
      echo "Warning: Failed to load zsh-autosuggestions"
    fi
  fi

  # Load zsh-history-substring-search
  if [[ -f ~/dot_files/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    if ! source ~/dot_files/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh; then
      echo "Warning: Failed to load zsh-history-substring-search"
    fi
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

  # Auto CD to directories without typing cd
  setopt autocd

  # Correct typos in command names
  setopt correct

  # Custom keybindings
  # Ctrl+Space to accept autosuggestion
  bindkey '^ ' autosuggest-accept
}

# Initialize Oh My Posh
if [[ -f ~/.local/bin/oh-my-posh ]] && is_zsh; then
  # Try to initialize Oh My Posh with error handling
  if ! OMP_CACHE_DIR="$HOME/.cache/oh-my-posh" ~/.local/bin/oh-my-posh init zsh --config ~/dot_files/zsh/oh-my-posh-config.json 2>/dev/null | source /dev/stdin; then
    echo "Warning: Oh My Posh failed to initialize. Using default prompt."
    PS1="%n@%m:%~%# "
  fi
elif [[ -f ~/.local/bin/oh-my-posh ]]; then
  # Oh My Posh is installed but we're not in a ZSH environment
  echo "Info: Oh My Posh available but not in ZSH environment."
  if [[ -n "$ZSH_VERSION" ]]; then
    PS1="%n@%m:%~%# "
  else
    PS1="\u@\h:\w\$ "
  fi
else
  # Fallback prompt if Oh My Posh is not installed
  if [[ -n "$ZSH_VERSION" ]]; then
    PS1="%n@%m:%~%# "
  else
    PS1="\u@\h:\w\$ "
  fi
fi

# Initialize ZSH modules properly (only when in ZSH)
if is_zsh; then
  init_zsh_features
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# fnm (Node.js version manager)
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  # Only initialize fnm if we're in an interactive shell
  if [[ $- == *i* ]]; then
    eval "`fnm env`"
  fi
fi
