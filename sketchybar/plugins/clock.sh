#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

sketchybar --set "$NAME" \
  icon.drawing=off \
  label.padding_left=10 \
  label="$(date '+%d/%m %H:%M')" \
  refresh=60
