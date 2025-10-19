#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
#
# Loads defined colors
source "$CONFIG_DIR/colors.sh"

# Interfaz Wi-Fi (en la mayoría de Macs suele ser en0, pero lo sacamos seguro)
WIFI_IF=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')

# Interfaz por la que sales a Internet ahora mismo (Wi-Fi o Ethernet)
ACTIVE_IF=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')

# IP de la interfaz activa
IP_ADDRESS=$(ipconfig getifaddr "$ACTIVE_IF" 2>/dev/null || echo "0.0.0.0")
# SSID solo si la activa es la Wi-Fi
if [[ "$ACTIVE_IF" == "$WIFI_IF" ]]; then
  SSID=$(networksetup -getairportnetwork "$WIFI_IF" 2>/dev/null | sed -E 's/^Current Wi(-Fi)? Network: //')
else
  SSID=""
fi
# CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

if [[ $SSID != "" ]]; then

  ICON_COLOR=$PINE
  ICON=󰖩
elif [[ $CURRENT_WIFI = "AirPort: Off" ]]; then
  ICON_COLOR=$PINE
  ICON=󰖪
else
  ICON=󰖪
fi

render_bar_item() {
  #DRAWING=$([ "$(cat /tmp/sketchybar_sender)" == "focus_on" ] && echo "off" || echo "on")
  DRAWING=on
  sketchybar --set $NAME \
    icon.color=$PINE \
    icon=$ICON \
    drawing=$DRAWING
}

render_popup() {
  if [ "$SSID" != "" ]; then
    args=(
      --set wifi.ssid label="$SSID"
      --set wifi.ipaddress label="$IP_ADDRESS"
      click_script="printf $IP_ADDRESS | pbcopy;sketchybar --set wifi popup.drawing=toggle"
    )
  else
    args=(
      --set wifi.ssid label="Not connected"
      --set wifi.ipaddress label="No IP"
    )
  fi

  sketchybar "${args[@]}" >/dev/null
}

update() {
  render_bar_item
  render_popup
}

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced")
  update
  ;;
"mouse.clicked")
  popup toggle
  ;;
esac
