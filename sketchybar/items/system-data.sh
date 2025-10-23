#!/usr/bin/env bash
#$ITEM_DIR/stats.sh

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

export CPU=􀫥
export DISK=􀤄
export MEMORY=􀫦
cpu=(
  label.color="$LABEL_COLOR"
  icon="$CPU"
  icon.color="$BLUE"
  update_freq=60
  script="$PLUGIN_DIR/cpu.sh"
)

memory=(
  label.color="$TEXT"
  icon="$MEMORY"
  icon.color="$GREEN"
  update_freq=65
  script="$PLUGIN_DIR/ram.sh"
)

disk=(
  label.color="$TEXT"
  icon="$DISK"
  icon.color="$MAROON"
  update_freq=60
  script="$PLUGIN_DIR/disk.sh"
)

sketchybar --add item disk right \
  --set disk "${disk[@]}" \
  --add item cpu right \
  --set cpu "${cpu[@]}" \
  --add item memory right \
  --set memory "${memory[@]}"
