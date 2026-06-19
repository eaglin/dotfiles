#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"

yabai_mode=$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].type')

case "$yabai_mode" in
  bsp)
    icon="▦"
    icon_color="$FOAM"
    ;;
  stack)
    icon="☰"
    icon_color="$IRIS"
    ;;
  float)
    icon="▢"
    icon_color="$GOLD"
    ;;
  *)
    icon="?"
    icon_color="$TEXT"
    ;;
esac

sketchybar --set yabai icon="$icon" icon.color="$icon_color"