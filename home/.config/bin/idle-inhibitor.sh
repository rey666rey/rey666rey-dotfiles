#!/bin/bash

PID_FILE="$HOME/.cache/idle_inhibit.pid"

is_enabled() {
    [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

refresh_waybar() {
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

toggle() {
    if is_enabled; then
        kill "$(cat "$PID_FILE")"
        rm -f "$PID_FILE"
    else
        mkdir -p "$(dirname "$PID_FILE")"
        systemd-inhibit --what=sleep --why="Manual keep-awake mode from Waybar" sleep infinity &
        echo $! >"$PID_FILE"
    fi

    refresh_waybar
}

lock_unless_enabled() {
    if is_enabled; then
        exit 0
    fi

    pidof hyprlock >/dev/null || hyprlock
}

status_json() {
    if is_enabled; then
        echo '{"text":"󰅶","class":"active","tooltip":"Режим: не засыпать и не блокировать экран\nЛКМ: вернуть обычный режим"}'
    else
        echo '{"text":"󰒲","class":"inactive","tooltip":"Режим: обычный\nКомпьютер блокируется и засыпает как сейчас\nЛКМ: не давать засыпать"}'
    fi
}

case "$1" in
--toggle) toggle ;;
--lock-unless-enabled) lock_unless_enabled ;;
--is-enabled) is_enabled ;;
*) status_json ;;
esac
