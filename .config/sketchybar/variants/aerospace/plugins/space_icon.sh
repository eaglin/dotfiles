#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused --format "%{workspace}" 2>/dev/null)

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$IRIS" \
    label.color="$BASE"
else
  APPS=$(aerospace list-windows --workspace "$1" --count 2>/dev/null)

  if [ "$APPS" = 0 ]; then
    sketchybar --set "$NAME" \
      background.drawing=on \
      background.color="$HIGHLIGHT_MED" \
      label.color="$OVERLAY0" \
      background.border_width=0 \
      background.border_color="$SURFACE"
  else
    sketchybar --set "$NAME" \
      background.drawing=on \
      background.border_color="$OVERLAY0" \
      background.color="$HIGHLIGHT_MED" \
      background.border_width=0 \
      label.highlight_color=$IRIS \
      label.color="$IRIS" \
      icon.highlight=false
  fi
fi
