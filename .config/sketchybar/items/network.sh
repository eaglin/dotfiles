#!/bin/bash

network_down=(
  update_freq=2
  script="$PLUGIN_DIR/network.sh"
  icon=󰇚
  label.width=60
  icon.color=$LOVE
  label.color=$LOVE
  padding_left=5
  padding_right=2
)

network_up=(
  icon=󰕒
  icon.color=$FOAM
  label.color=$FOAM
  label.width=60
  padding_left=2
  padding_right=5
)

sketchybar \
  --add item network.down right \
  --set network.down "${network_down[@]}" \
  --add item network.up right \
  --set network.up "${network_up[@]}"
