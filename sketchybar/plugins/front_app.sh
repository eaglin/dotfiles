#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

CONFIG_DIR="$HOME/.config/sketchybar"

if [ "$SENDER" = "front_app_switched" ]; then
  # Obtener el icono usando el mapeo personalizado
  app_icon=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$INFO")

  sketchybar --set "$NAME" \
    label="$INFO" \
    icon.drawing=off
fi
