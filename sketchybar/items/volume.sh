#!/bin/bash

volume=(
  icon.padding_right=5
  update_freq=10
  script="$PLUGIN_DIR/volume.sh"
  --subscribe volume volume_change
)

sketchybar \
  --add item volume right \
  --set volume "${volume[@]}"
