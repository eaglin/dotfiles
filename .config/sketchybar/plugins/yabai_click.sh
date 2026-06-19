#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"

current_mode=$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].type')
focused_space=$(yabai -m query --spaces --display | jq 'map(select(."has-focus" == true))[0].index')

case "$current_mode" in
  bsp)
    yabai -m config --space "$focused_space" layout stack
    ;;
  stack)
    yabai -m config --space "$focused_space" layout float
    ;;
  float)
    yabai -m config --space "$focused_space" layout bsp
    ;;
esac

sleep 0.5

new_mode=$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].type')

case "$new_mode" in
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