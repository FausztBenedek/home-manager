#!/usr/bin/env sh

# Lock screen
hyprlock &

# Wallpaper
hyprpaper &

# Adds the network stuff to waybar
nm-applet --indicator &

# Bluetooth applet
blueman-applet &

waybar &
