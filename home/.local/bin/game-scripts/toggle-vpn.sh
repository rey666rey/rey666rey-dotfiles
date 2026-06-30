#!/bin/bash

# Path to the Python policy switcher project
PROJECT_DIR="/home/rey/Documents/keenetic_switch"
POLICY_SCRIPT="$PROJECT_DIR/scripts/keenetic_control.py"

echo "🎮 Запуск игры с управлением VPN..."

# Check if game command was provided
if [ $# -eq 0 ]; then
    echo "❌ Ошибка: не указана команда запуска игры"
    echo "Использование: $0 <команда_игры> [аргументы]"
    exit 1
fi

# Get current policy status
echo "🔍 Проверяем текущую политику..."
CURRENT_POLICY=$(python3 "$POLICY_SCRIPT" status 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "❌ Ошибка: не удалось определить текущую политику"
    exit 1
fi

echo "📡 Текущая политика: $CURRENT_POLICY"

# Flag to track if we need to restore XKeen
RESTORE_XKEEN=false

# If XKeen is active, switch to Default before launching the game
if [ "$CURRENT_POLICY" = "XKeen" ]; then
    echo "🔄 Выключаем XKeen для игры..."
    python3 "$POLICY_SCRIPT" default
    
    if [ $? -ne 0 ]; then
        echo "❌ Ошибка переключения политики, игра не будет запущена"
        exit 1
    fi
    
    RESTORE_XKEEN=true
    echo "✅ XKeen выключен"
else
    echo "ℹ️  XKeen уже выключен, запускаем игру"
fi

# Launch the game with all arguments
echo "🚀 Запуск игры..."
"$@"

# Capture the exit code
EXIT_CODE=$?

echo ""
echo "🎮 Игра завершена (код выхода: $EXIT_CODE)"

# Restore XKeen if we turned it off
if [ "$RESTORE_XKEEN" = true ]; then
    echo "🔄 Включаем XKeen обратно..."
    python3 "$POLICY_SCRIPT" xkeen
    
    if [ $? -eq 0 ]; then
        echo "✅ XKeen включен"
    else
        echo "⚠️  Предупреждение: не удалось включить XKeen обратно"
    fi
else
    echo "ℹ️  XKeen не был выключен, оставляем как есть"
fi

# Exit with the same code as the game
exit $EXIT_CODE
