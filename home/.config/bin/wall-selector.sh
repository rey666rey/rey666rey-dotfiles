#!/bin/bash
set -euo pipefail

CACHE_DIR="$HOME/.cache"
LOCK_BG_PATH="$CACHE_DIR/lock_background"
CURRENT_WALL_PATH="$CACHE_DIR/current_wallpaper"

for cmd in matugen vicinae find; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: required command '$cmd' is not installed or not in PATH."
        exit 127
    fi
done

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <wallpapers-directory>"
    exit 1
fi

DIR="$1"
if [[ ! -d "$DIR" ]]; then
    echo "Directory not found: $DIR"
    exit 1
fi

# Select a wallpaper
SELECTED=$(
    find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) |
        sort |
        vicinae dmenu --no-metadata -p " Pick a wallpaper..."
)
[[ -z "$SELECTED" ]] && exit 0

# Set the selected image
if command -v swww >/dev/null 2>&1 || command -v awww >/dev/null 2>&1; then
    wallpaper_cmd="swww"
    daemon_cmd="swww-daemon"

    if ! command -v "$wallpaper_cmd" >/dev/null 2>&1; then
        wallpaper_cmd="awww"
        daemon_cmd="awww-daemon"
    fi

    if ! pgrep -x "$daemon_cmd" >/dev/null 2>&1; then
        nohup "$daemon_cmd" >/dev/null 2>&1 &
        sleep 0.5
    fi

    rand() { printf "0.%02d\n" $((RANDOM % 100)); }

    px=$(rand)
    py=$(rand)
    transition_pos="$px,$py"

    "$wallpaper_cmd" img "$SELECTED" \
        -t grow \
        --transition-pos "$transition_pos" \
        --transition-duration 1.8 \
        --transition-step 255 \
        --transition-fps 60
elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg >/dev/null 2>&1 || true
    nohup swaybg -i "$SELECTED" -m fill >/dev/null 2>&1 &
else
    echo "Error: neither 'swww' nor 'swaybg' is installed."
    exit 127
fi

# Generate a color palette, but do not block wallpaper changes on failure.
if ! matugen image "$SELECTED"; then
    echo "Warning: matugen failed for '$SELECTED'." >&2
fi

# Set the lock background
mkdir -p "$CACHE_DIR"
if ! cp "$SELECTED" "$LOCK_BG_PATH"; then
    echo "Warning: failed to update lock background cache." >&2
fi
if ! printf '%s\n' "$SELECTED" >"$CURRENT_WALL_PATH"; then
    echo "Warning: failed to persist current wallpaper path." >&2
fi

echo "Lock background saved to: $LOCK_BG_PATH"
