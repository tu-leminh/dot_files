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

# Oh My Posh Configuration
# Check if Oh My Posh is installed and configure it
if [ -f ~/.local/bin/oh-my-posh ]; then
    # Set the Oh My Posh configuration file path
    OMP_CONFIG="$HOME/dot_files/zsh/oh-my-posh-config.json"
    
    # Check if the configuration file exists
    if [ -f "$OMP_CONFIG" ]; then
        # Initialize Oh My Posh with our custom configuration
        eval "$($HOME/.local/bin/oh-my-posh init zsh --config "$OMP_CONFIG")"
    else
        # Fallback to default configuration if ours isn't found
        echo "Warning: Custom Oh My Posh config not found, using default"
        eval "$($HOME/.local/bin/oh-my-posh init zsh)"
    fi
else
    # If Oh My Posh isn't installed, provide a nice default prompt
    PROMPT='%F{blue}%n%f@%F{green}%m%f:%F{yellow}%~%f %# '
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

# Add Go binaries to PATH if not already present
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
    export PATH="$PATH:$HOME/go/bin"
fi

# Auto-start tmux for all terminal sessions
if command -v tmux >/dev/null 2>&1; then
    if [[ $- == *i* ]] && [[ -z "$TMUX" ]]; then
        tmux attach-session -t main 2>/dev/null || tmux new-session -s main
    fi
fi
export PATH=$PATH:/home/mt/.local/bin
export EDITOR=nvim
export VISUAL=nvim
