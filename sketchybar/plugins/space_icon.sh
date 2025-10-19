CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh" # Importar colores

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused --format "%{workspace}")

# Todos los espacios en blanco
SPACE_COLOR="$TEXT"

if [ "$SENDER" == "mouse.entered" ]; then
  if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    exit 0
  fi
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$ROSE" \
    icon.color="$BASE"
  exit 0
fi

if [ "$SENDER" == "mouse.exited" ]; then
  if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    exit 0
  fi
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$TRANSPARENT" \
    icon.color="$TEXT"
  exit 0
fi

# icons=""
#
# APPS_INFO=$(aerospace list-windows --workspace "$1" --json --format "%{monitor-appkit-nsscreen-screens-id}%{app-name}")
#
# IFS=$'\n'
# for sid in $(echo "$APPS_INFO" | jq -r "map ( .\"app-name\" ) | .[]"); do
#   icons+=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$sid")
#   icons+="  "
# done
# When icons is empty, show just the workspace number centered
# if [ -z "$icons" ]; then
#   if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     sketchybar --animate sin 10 \
#       --set "$NAME" \
#       y_offset=5 y_offset=0 \
#       background.drawing=on
#
#     sketchybar --set "$NAME" \
#       drawing=on \
#       label="" \
#       label.padding_right=5 \
#       icon.padding_left=10 \
#       background.color="$HIGHLIGHT_HIGH" \
#
#   else
#     sketchybar --set "$NAME" \
#       drawing=on \
#       label="" \
#       label.padding_right=5 \
#       icon.padding_left=10 \
#       background.drawing=off \
#       icon.color="$SPACE_COLOR"
#   fi
# else
# if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#   sketchybar --animate sin 10 \
#     --set "$NAME" \
#     y_offset=5 y_offset=0 \
#     background.drawing=on
#
#   sketchybar --set "$NAME" \
#     drawing=on \
#     label="$icons" \
#     label.y_offset=-1 \
#     label.color="$SPACE_COLOR" \
#     icon.color="$SPACE_COLOR" \
#     background.color="$HIGHLIGHT_HIGH"
# else

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  # sketchybar --animate sin 10 \
  #   --set "$NAME" \
  #   y_offset=5 y_offset=0

  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$IRIS_TRANSPARENT" \
    background.corner_radius=3 \
    background.height=17 \
    label.drawing=off \
    icon.color="$TEXT"

else
  sketchybar --set "$NAME" \
    background.drawing=off \
    label.drawing=off \
    icon.color="$TEXT"
fi
# fi
