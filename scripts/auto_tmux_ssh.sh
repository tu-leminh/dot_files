#!/bin/bash
# Auto-start tmux when connecting via SSH
# This script should be added to your shell profile (.bashrc or .zshrc)

# Check if we're in an SSH session
if [[ -n "$SSH_CONNECTION" ]]; then
    # Check if tmux is installed
    if command -v tmux >/dev/null 2>&1; then
        # Check if we're already in a tmux session
        if [[ -z "$TMUX" ]]; then
            # Attach to an existing tmux session or create a new one
            tmux attach-session -t ssh_tmux 2>/dev/null || tmux new-session -s ssh_tmux
        fi
    fi
fi