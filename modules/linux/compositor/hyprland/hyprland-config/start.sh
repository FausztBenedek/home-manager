#!/usr/bin/env sh

# Lock screen Disable, because I boot into Hyprland directly (for now)
# hyprlock &

# Wallpaper
hyprpaper &

# Adds the network stuff to waybar
nm-applet --indicator &

# Bluetooth applet
blueman-applet &

waybar &
