#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

sketchybar --set "$NAME" \
  icon.drawing=on \
  icon="􀉉" \
  label.padding_left=10 \
  label="$(date '+%a %b %d %H:%M')" \
  refresh=60
