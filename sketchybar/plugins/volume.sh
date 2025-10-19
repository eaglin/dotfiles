#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
  [6-9][0-9] | 100)
    ICON="󰕾"
    COLOR=$TEXT
    ;;
  [3-5][0-9])
    ICON="󰖀"
    COLOR=$TEXT
    ;;
  [1-9] | [1-2][0-9])
    ICON="󰕿"
    COLOR=$TEXT
    ;;
  *)
    ICON="󰖁"
    COLOR=$LOVE # Alert: volumen mute
    ;;
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" icon.color="$ROSE" label.color="$WHITE"
fi
