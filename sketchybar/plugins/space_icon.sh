CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors-catppuccin.sh" # Importar colores
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused --format "%{workspace}")

# if [ "$SENDER" == "mouse.entered" ]; then
#   if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     exit 0
#   fi
#   sketchybar --set "$NAME" \
#     background.drawing=on \
#     background.color="$CRUST" \
#     icon.color="$BASE"
#   exit 0
# fi
#
# if [ "$SENDER" == "mouse.exited" ]; then
#   if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     exit 0
#   fi
#   sketchybar --set "$NAME" \
#     background.drawing=on \
#     background.color="$MANTLE" \
#     icon.color="$TEXT"
#   exit 0
# fi

# icons=""
#
# APPS_INFO=$(aerospace list-windows --workspace "$1" --json --format "%{monitor-appkit-nsscreen-screens-id}%{app-name}")
#
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  # sketchybar --animate sin 10 \
  #   --set "$NAME" \
  #   y_offset=5 y_offset=0

  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$LAVENDER" \
    background.border_color="$LAVENDER" \
    background.border_width=2 \
    icon.higlight=true \
    icon.color="$CRUST" \
    background.corner_radius=6

else

  APPS=$(aerospace list-windows --workspace "$1" --count)
  if [ "$APPS" = 0 ]; then
    # No hay aplicaciones en este espacio
    sketchybar --set "$NAME" \
      background.drawing=on \
      background.color="$SURFACE0" \
      background.border_color="$SURFACE0" \
      background.corner_radius=6 \
      icon.color="$OVERLAY1" \
      icon.higlight=true

  else
    sketchybar --set "$NAME" \
      background.drawing=on \
      background.border_color="$LAVENDER" \
      background.color="$SURFACE0" \
      background.border_width=2 \
      background.corner_radius=6 \
      icon.highlight_color=$CRUST \
      icon.color="$TEXT" \
      icon.highlight=false
  fi
fi

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

# fi
