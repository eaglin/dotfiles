#!/bin/bash
sketchybar --add item chevron left \
  --set chevron icon="|" label.drawing=off \
  --add item front_app left \
  --set front_app \
  script="$PLUGIN_DIR/front_app.sh" \
  label.color=$TEXT \
  label.padding_right=15 \
  icon.padding_left=15 \
  padding_left=5 \
  blur_radius=5 \
  background.color=$SURFACE0 \
  background.corner_radius=1 \
  background.height=24 \
  background.border_width=1 \
  background.border_color=$BLUE \
  background.corner_radius=6 \
  icon.drawing=on \
  icon.font="sketchybar-app-font:Regular:16.0" \
  --subscribe front_app front_app_switched aerospace_workspace_change
