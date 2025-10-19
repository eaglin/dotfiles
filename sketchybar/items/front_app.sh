#!/bin/bash
sketchybar --add item front_app left \
  --set front_app icon.drawing=on script="$PLUGIN_DIR/front_app.sh" \
  label.color=$TEXT \
  label.padding_left=5 \
  icon.padding_right=5 \
  padding_left=5 \
  background.color=$IRIS_TRANSPARENT \
  background.corner_radius=1 \
  background.height=26 \
  background.border_width=1 \
  background.border_color=$IRIS \
  --subscribe front_app front_app_switched
