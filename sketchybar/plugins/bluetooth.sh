#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/bluetooth.sh

source "$HOME/.config/sketchybar/colors.sh"

ICON="󰂯" # Nerd Font Bluetooth
COLOR_ON="$IRIS"
COLOR_OFF="0x66ffffff"

open_bt_popup() {
  # Intenta abrir configuración de Bluetooth directamente
  # Estas URLs funcionan sin permisos especiales

  # Primero intenta abrir las preferencias de Bluetooth modernas
  if open "x-apple.systempreferences:com.apple.BluetoothSettings" 2>/dev/null; then
    return 0
  fi

  # Fallback para versiones más antiguas
  if open "x-apple.systempreferences:com.apple.preference.bluetooth" 2>/dev/null; then
    return 0
  fi

  # Último recurso: prefpane directo
  open "/System/Library/PreferencePanes/Bluetooth.prefPane" 2>/dev/null
}

bt_power() {
  # Prioriza blueutil si está instalado (más rápido y fiable)
  if command -v blueutil >/dev/null 2>&1; then
    blueutil --power 2>/dev/null || echo 0
    return
  fi
  # Fallback sin dependencias
  /usr/bin/defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null || echo 0
}

bt_connected_count() {
  if command -v blueutil >/dev/null 2>&1; then
    # Cuenta dispositivos conectados con blueutil
    blueutil --paired --format json 2>/dev/null |
      /usr/bin/awk 'BEGIN{c=0} /"connected": *true/{c++} END{print c+0}'
    return
  fi
  # Fallback sin dependencias: cuenta "Connected: Yes" o "Conectado: Sí"
  /usr/sbin/system_profiler SPBluetoothDataType 2>/dev/null |
    /usr/bin/grep -E "Connected: Yes|Conectado: S[ií]" -c | tr -d ' '
}

update() {
  POWER="$(bt_power)"
  if [ "$POWER" = "1" ]; then
    COUNT="$(bt_connected_count)"
    if [ "$COUNT" -gt 0 ]; then
      LABEL="$COUNT"
      COLOR="$COLOR_ON"
    else
      LABEL="On"
      COLOR="$COLOR_ON"
    fi
  else
    LABEL="Off"
    COLOR="$COLOR_OFF"
  fi

  sketchybar --set "bt" icon="$ICON" icon.color="$COLOR" label="$LABEL"
}

case "$SENDER" in
"mouse.clicked")
  open_bt_popup
  ;;
*)
  update
  ;;
esac
