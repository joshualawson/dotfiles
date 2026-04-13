#!/usr/bin/env bash

# Simple volume slider for Waybar using zenity with Tokyo Night theme

DIR="$HOME/.config/waybar/scripts"
CSS="$DIR/volume-style.css"

# Create temp config dir with our theme
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/gtk-3.0"
cp "$CSS" "$TMPDIR/gtk-3.0/gtk.css"

# Get current volume
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

current=$(get_volume)

# Show slider with custom theme
new_vol=$(XDG_CONFIG_HOME="$TMPDIR" zenity --scale \
    --title="Volume" \
    --text="" \
    --min-value=0 \
    --max-value=100 \
    --value="$current" \
    --step=5 \
    --width=280 \
    --height=80 \
    2>/dev/null)

# Cleanup
rm -rf "$TMPDIR"

if [[ -n "$new_vol" ]]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${new_vol}%"
fi
