#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
sketchybar --add event aerospace_workspace_change

for sid in 1 2 3 4 5 6 7 8 9 0; do
  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" aerospace_workspace_change display_change system_woke \
    --set space."$sid" \
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
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/space_icon.sh $sid"
done
