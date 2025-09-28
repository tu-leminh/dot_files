# Wallpapers

This directory contains the wallpaper used by the sway configuration.

## Setup

The sway configuration expects a wallpaper file named `wallpaper.png`. 
You need to create a symlink from `~/Pictures/Wallpapers` to this directory in the dotfiles for sway and swaylock to work properly:

```bash
# Remove any existing Pictures/Wallpapers directory
rm -rf ~/Pictures/Wallpapers

# Create the symlink
ln -sf /path/to/your/dotfiles/wallpapers ~/Pictures/Wallpapers
```

Alternatively, you can copy your preferred wallpaper as `wallpaper.png` to `~/Pictures/Wallpapers/`.

## Current Wallpaper

The sway and swaylock configurations expect a wallpaper file named `wallpaper.png`.

## Swaylock Integration

The swaylock configuration uses this same wallpaper as the lock screen background.