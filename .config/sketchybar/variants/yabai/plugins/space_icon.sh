#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
FOCUSED_WORKSPACE=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index')

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$IRIS" \
    label.color="$BASE"
else
  APPS=$(yabai -m query --windows --space "$1" 2>/dev/null | jq 'length')

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
