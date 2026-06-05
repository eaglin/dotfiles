#!/bin/bash

POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

power_menu=(
  icon=󰐥
  icon.y_offset=1
  icon.font="Hack Nerd Font:Bold:18.0"
  icon.color=0xffed8796
  label.drawing=off
  icon.padding_right=4
  icon.padding_left=5
  background.color=$SURFACE0
  background.corner_radius=30
  background.border_color=0xffed8796
  background.height=20
  popup.y_offset=10
  popup.blur_radius=20
  script="$PLUGIN_DIR/power_menu.sh"
  click_script="$PLUGIN_DIR/power_menu.sh mouse.clicked"
)

sketchybar --add item power_menu right \
  --set power_menu "${power_menu[@]}"
