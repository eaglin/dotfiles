#!/bin/bash

volume=(
  icon.font="JetBrainsMono Nerd Font:Bold:16.0"
  icon.color=$ROSE
  label.drawing=on
  label.font="JetBrainsMono Nerd Font:Bold:13.0"
  label.color=$TEXT
  background.drawing=off
  update_freq=10
  script="$PLUGIN_DIR/volume.sh"
  --subscribe volume volume_change
)

sketchybar \
  --add item volume right \
  --set volume "${volume[@]}"
