#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/bluetooth_popup.sh

source "$HOME/.config/sketchybar/colors.sh"

ICON="󰂯" # Nerd Font Bluetooth
COLOR_ON="$IRIS"
COLOR_OFF="0x66ffffff"

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

populate_popup() {
  # Limpia el popup existente
  sketchybar --remove '/bt\.device\..*/'

  if [ "$(bt_power)" != "1" ]; then
    sketchybar --add item bt.bluetooth_off popup.bt \
               --set bt.bluetooth_off label="Bluetooth está apagado" \
                                     icon="⚠️" \
                                     icon.color=0xfff5a97f \
                                     label.color=0xfff5a97f
    return
  fi

  # Obtener dispositivos emparejados
  local devices=""
  if command -v blueutil >/dev/null 2>&1; then
    devices=$(blueutil --paired --format json 2>/dev/null)
  fi

  if [ -z "$devices" ] || [ "$devices" = "[]" ]; then
    sketchybar --add item bt.no_devices popup.bt \
               --set bt.no_devices label="No hay dispositivos emparejados" \
                                   icon="📱" \
                                   icon.color=0x66ffffff \
                                   label.color=0x66ffffff
    return
  fi

  # Parsear dispositivos y añadirlos al popup
  echo "$devices" | /usr/bin/jq -r '.[] | @base64' 2>/dev/null | while read -r device_b64; do
    if [ -n "$device_b64" ]; then
      device=$(echo "$device_b64" | base64 --decode)
      name=$(echo "$device" | /usr/bin/jq -r '.name // "Dispositivo desconocido"')
      connected=$(echo "$device" | /usr/bin/jq -r '.connected // false')
      address=$(echo "$device" | /usr/bin/jq -r '.address // ""')

      # Determinar icono y color según el estado
      if [ "$connected" = "true" ]; then
        icon="●"
        color="0xff007AFF"  # Azul de iOS/macOS
        action="blueutil --disconnect '$address'"
      else
        icon="○"
        color="0x66ffffff"  # Gris claro
        action="blueutil --connect '$address'"
      fi

      # Crear item único para cada dispositivo
      item_name="bt.device.$(echo "$address" | tr ':' '_')"

      sketchybar --add item "$item_name" popup.bt \
                 --set "$item_name" label="$name" \
                                    icon="$icon" \
                                    icon.color="$color" \
                                    label.color="$color" \
                                    click_script="$action; \$HOME/.config/sketchybar/plugins/bluetooth_popup.sh update_and_close"
    fi
  done

  # Agregar separador y opciones adicionales
  sketchybar --add item bt.separator popup.bt \
             --set bt.separator icon="—" \
                               icon.color=0x66ffffff \
                               label.drawing=off \
             --add item bt.preferences popup.bt \
             --set bt.preferences label="Abrir Configuración..." \
                                 icon="⚙️" \
                                 icon.color=0x66ffffff \
                                 label.color=0x66ffffff \
                                 click_script="open 'x-apple.systempreferences:com.apple.BluetoothSettings'; sketchybar --set bt popup.drawing=off"
}

toggle_popup() {
  local popup_state=$(sketchybar --query bt | /usr/bin/jq -r '.popup.drawing')

  if [ "$popup_state" = "on" ]; then
    sketchybar --set bt popup.drawing=off
  else
    populate_popup
    sketchybar --set bt popup.drawing=on
  fi
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

case "${1:-$SENDER}" in
"mouse.clicked")
  toggle_popup
  ;;
"update_and_close")
  sleep 1
  update
  sketchybar --set bt popup.drawing=off
  ;;
*)
  update
  ;;
esac