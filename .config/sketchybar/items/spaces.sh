#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
sketchybar --add event yabai_space_change

for sid in 1 2 3 4 5 6 7 8 9; do
  sketchybar --add space space."$sid" left \
    --set space."$sid" \
    space="$sid" \
    label="$sid" \
    background.drawing=on \
    background.corner_radius=14 \
    label.font="JetBrainsMono Nerd Font:Bold:14.0" \
    icon.drawing=off \
    background.height=18 \
    label.padding_right=6 \
    label.padding_left=6 \
    padding_left=6 \
    padding_right=6 \
    click_script="yabai -m space --focus $sid" \
    script="$CONFIG_DIR/plugins/space_icon.sh $sid" \
    --subscribe space."$sid" yabai_space_change space_change display_change system_woke
done
