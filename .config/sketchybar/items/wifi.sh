#!/bin/bash

POPUP_OFF="sketchybar --set wifi popup.drawing=off"

wifi=(
  icon.font="JetBrainsMono Nerd Font:Bold:16.0"
  icon.color=$TEXT
  icon.padding_left=8
  label.drawing=off
  label.font="JetBrainsMono Nerd Font:Bold:13.0"
  label.color=$TEXT
  background.drawing=off
  popup.align=right
  update_freq=60
  script="$PLUGIN_DIR/wifi.sh"
  --subscribe wifi wifi_change
  mouse.clicked
  mouse.exited
  mouse.exited.global
)

sketchybar \
  --add item wifi right \
  --set wifi "${wifi[@]}" \
  --add item wifi.ssid popup.wifi \
  --set wifi.ssid icon=􀅴 \
  label="SSID" \
  click_script="open 'x-apple.systempreferences:com.apple.preference.network?Wi-Fi';$POPUP_OFF" \
  --add item wifi.ipaddress popup.wifi \
  --set wifi.ipaddress icon=􀆪 \
  click_script="echo \"$IP_ADDRESS\"|pbcopy;$POPUP_OFF"
