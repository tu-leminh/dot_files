#!/bin/bash
# Test configuration module

# Source utility functions
# Note: SCRIPT_DIR is expected to be set by the main script before sourcing this module
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/utils.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
else
    echo "Error: utils.sh not found!" >&2
    exit 1
fi

# Function to test ZSH configuration
test_config() {
    log_info "Testing ZSH configuration..."

    # Test 1: Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        log_error "zsh is not installed"
        exit 1
    fi
    log_success "zsh is installed ($(zsh --version 2>/dev/null))"

    # Test 2: Check if .zshrc file exists
    if [ ! -f ~/.zshrc ]; then
        log_error "~/.zshrc does not exist"
        exit 1
    fi
    log_success "~/.zshrc exists"

    # Test 3: Check if required files exist
    required_files=(
        "$DOTFILES_DIR/zsh/oh-my-posh-config.json"
        "$DOTFILES_DIR/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "$DOTFILES_DIR/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "$DOTFILES_DIR/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
    )

    all_files_exist=true
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Required file $file does not exist"
            all_files_exist=false
        fi
    done

    if [ "$all_files_exist" = true ]; then
        log_success "All required configuration files exist"
    else
        log_error "Some required files are missing. Run with --apply-configs to fix."
        exit 1
    fi

    # Test 4: Check if submodules are properly initialized
    log_info "Checking submodule status..."
    cd "$DOTFILES_DIR"
    submodule_status=$(git submodule status 2>&1)
    if echo "$submodule_status" | grep -q "^-"; then
        log_warning "Some submodules are not initialized"
        echo "$submodule_status" | grep "^-" | while read line; do
            log_warning "Uninitialized submodule: $(echo "$line" | cut -d' ' -f2)"
        done
    else
        log_success "All submodules are properly initialized"
    fi

    # Test 5: Check if zsh can source .zshrc without critical errors
    log_info "Testing zsh configuration load..."
    zsh_output=$(timeout 10s zsh -i -c "echo 'ZSH loaded successfully'" 2>&1)
    if [ $? -eq 124 ]; then
        log_warning "ZSH configuration test timed out (may be due to tmux auto-start)"
    elif echo "$zsh_output" | grep -q "ZSH loaded successfully"; then
        log_success ".zshrc loads without critical errors"
    else
        log_warning "Potential issues when loading .zshrc:"
        echo "$zsh_output" | head -5
    fi

    log_success "ZSH configuration test completed."
}