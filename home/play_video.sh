#!/bin/bash

# Закрываем все активные окна в Hyprland
for window in $(hyprctl clients -j | jq -r '.[].address'); do
    hyprctl dispatch closewindow address:$window
done

sleep 1

VIDEO_PATH="/home/rey/Videos/final.mp4"

# Переключаемся на первый монитор и запускаем первый VLC (со звуком)
hyprctl dispatch focusmonitor DP-1
vlc --fullscreen --play-and-exit --no-video-title-show "$VIDEO_PATH" > /dev/null 2>&1 &

# Ждем появления первого окна VLC
sleep 2

# Получаем адрес первого окна VLC и убеждаемся что оно на DP-1
VLC1_ADDR=$(hyprctl clients -j | jq -r '.[] | select(.class=="vlc") | .address' | head -1)
if [ -n "$VLC1_ADDR" ]; then
    hyprctl dispatch movewindow mon:DP-1,address:$VLC1_ADDR
fi

# Переключаемся на второй монитор и запускаем второй VLC (без звука)
hyprctl dispatch focusmonitor eDP-2
vlc --fullscreen --play-and-exit --no-video-title-show --no-audio "$VIDEO_PATH" > /dev/null 2>&1 &

# Ждем появления второго окна VLC
sleep 2

# Получаем адрес второго окна VLC и перемещаем на eDP-2
VLC2_ADDR=$(hyprctl clients -j | jq -r '.[] | select(.class=="vlc") | .address' | tail -1)
if [ -n "$VLC2_ADDR" ] && [ "$VLC2_ADDR" != "$VLC1_ADDR" ]; then
    hyprctl dispatch movewindow mon:eDP-2,address:$VLC2_ADDR
fi

sleep 1

# Логирование
echo "$(date): Video playback started on two monitors, WAYLAND_DISPLAY=$WAYLAND_DISPLAY, XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR" >> /home/rey/video_playback.log
