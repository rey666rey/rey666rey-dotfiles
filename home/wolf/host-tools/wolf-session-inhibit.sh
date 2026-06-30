#!/usr/bin/env bash
set -euo pipefail

inhibitor_pid=""

cleanup() {
    if [[ -n "${inhibitor_pid}" ]] && kill -0 "${inhibitor_pid}" 2>/dev/null; then
        kill "${inhibitor_pid}" 2>/dev/null || true
        wait "${inhibitor_pid}" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

start_inhibitor() {
    if [[ -n "${inhibitor_pid}" ]] && kill -0 "${inhibitor_pid}" 2>/dev/null; then
        return
    fi

    systemd-inhibit \
        --what=idle:sleep \
        --who="Wolf XFCE" \
        --why="Moonlight/Wolf gaming session is active" \
        bash -lc 'while :; do sleep 3600; done' &
    inhibitor_pid=$!
}

stop_inhibitor() {
    if [[ -z "${inhibitor_pid}" ]]; then
        return
    fi

    if kill -0 "${inhibitor_pid}" 2>/dev/null; then
        kill "${inhibitor_pid}" 2>/dev/null || true
        wait "${inhibitor_pid}" 2>/dev/null || true
    fi
    inhibitor_pid=""
}

while :; do
    if docker ps --format '{{.Names}}' | grep -q '^WolfXFCE_'; then
        start_inhibitor
    else
        stop_inhibitor
    fi

    sleep 5
done
