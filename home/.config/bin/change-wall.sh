#!/bin/bash

set -euo pipefail

CACHE_DIR="$HOME/.cache"
LOCK_BG_PATH="$CACHE_DIR/lock_background"
CURRENT_WALL_PATH="$CACHE_DIR/current_wallpaper"

for cmd in matugen shuf find; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: required command '$cmd' is not installed or not in PATH."
        exit 127
    fi
done

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <wallpapers-folder>"
    exit 1
fi

folder=${1/#\~/$HOME}
if [[ ! -d "$folder" ]]; then
    echo "Error: directory '$folder' does not exist."
    exit 1
fi

# Get a random image from the folder
mapfile -t all_images < <(
    find "$folder" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | sort
)

if ((${#all_images[@]} == 0)); then
    echo "Error: no images found in '$folder'."
    exit 1
fi

mapfile -t shuffled_images < <(shuf -e "${all_images[@]}")

current_image=$(cat "$CURRENT_WALL_PATH" 2>/dev/null || true)
selected_image=""

for img in "${shuffled_images[@]}"; do
    if [[ "$img" != "$current_image" ]]; then
        selected_image="$img"
        break
    fi
done

if [[ -z "$selected_image" ]]; then
    selected_image="${all_images[RANDOM % ${#all_images[@]}]}"
fi

echo "Selected image: $selected_image"

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

    current_image=$("$wallpaper_cmd" query -a | grep -oP 'image:\s*\K.*' || true)
    if [[ "$selected_image" == "$current_image" ]]; then
        selected_image="${all_images[RANDOM % ${#all_images[@]}]}"
    fi

    rand() { printf "0.%02d\n" $((RANDOM % 100)); }
    px=$(rand)
    py=$(rand)
    transition_pos="$px,$py"

    "$wallpaper_cmd" img -t grow \
        --transition-pos "$transition_pos" \
        --transition-duration 1.8 \
        --transition-step 255 \
        --transition-fps 60 \
        "$selected_image"
elif command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg >/dev/null 2>&1 || true
    nohup swaybg -i "$selected_image" -m fill >/dev/null 2>&1 &
else
    echo "Error: neither 'swww' nor 'swaybg' is installed."
    exit 127
fi

# Generate a color palette, but do not block wallpaper changes on failure.
if ! matugen image "$selected_image"; then
    echo "Warning: matugen failed for '$selected_image'." >&2
fi

# Set the lock background
mkdir -p "$CACHE_DIR"
if ! cp "$selected_image" "$LOCK_BG_PATH"; then
    echo "Warning: failed to update lock background cache." >&2
fi
if ! printf '%s\n' "$selected_image" >"$CURRENT_WALL_PATH"; then
    echo "Warning: failed to persist current wallpaper path." >&2
fi

echo "Lock background saved to: $LOCK_BG_PATH"
