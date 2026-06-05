#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# Format: "Mon 12 Jan 19:15"
sketchybar --set "$NAME" \
  label="$(date '+%a %d %b %H:%M')"
