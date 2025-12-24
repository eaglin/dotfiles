#!/bin/bash
sketchybar --add item chevron left \
  --set chevron icon= \
  icon.font="Hack Nerd Font:Bold:16.0" \
  icon.color=$PEACH \
  label.drawing=off \
  icon.padding_left=20 \
  label.drawing=off \
  --add item front_app left \
  --set front_app \
  script="$PLUGIN_DIR/front_app.sh" \
  label.padding_right=15 \
  padding_left=5 \
  blur_radius=5 \
  icon.drawing=on \
  icon.font="sketchybar-app-font:Regular:18.0" \
  --subscribe front_app front_app_switched aerospace_workspace_change
