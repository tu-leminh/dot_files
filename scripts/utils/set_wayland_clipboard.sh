#!/bin/bash
# Helper script to properly set Wayland clipboard

if [ $# -eq 0 ]; then
    echo \"Usage: $0 \\\"text to copy to clipboard\\\"\"
    echo \"This script copies text to the Wayland clipboard using wl-copy\"
    exit 1
fi

# Copy to Wayland clipboard selection
echo -n \"$*\" | wl-copy

# Also copy to primary selection (for middle-click paste)
echo -n \"$*\" | wl-copy --primary

echo \"Text copied to Wayland clipboard\"