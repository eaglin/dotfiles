#!/bin/bash

set -euo pipefail

CONFIG_DIR="$HOME/.config/sketchybar"
variant="${1:-}"

case "$variant" in
  yabai) ;;
  *)
    printf 'Usage: %s yabai\n' "$(basename "$0")" >&2
    exit 1
    ;;
esac

cp "$CONFIG_DIR/variants/$variant/items/spaces.sh" "$CONFIG_DIR/items/spaces.sh"
cp "$CONFIG_DIR/variants/$variant/plugins/space_icon.sh" "$CONFIG_DIR/plugins/space_icon.sh"
chmod +x "$CONFIG_DIR/items/spaces.sh" "$CONFIG_DIR/plugins/space_icon.sh"
printf '%s\n' "$variant" > "$CONFIG_DIR/.window-manager"

if command -v sketchybar >/dev/null 2>&1; then
  sketchybar --reload
else
  printf 'SketchyBar config switched to %s. Restart/reload SketchyBar manually.\n' "$variant"
fi