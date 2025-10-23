#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors-catppuccin.sh" # Importar colores
sketchybar --add event aerospace_workspace_change
for sid in $(aerospace list-workspaces --all); do

  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" aerospace_workspace_change display_change system_woke \
    --set space."$sid" \
    icon="$sid" \
    icon.font="FiraCode Nerd Font:Bold:13.0" \
    background.drawing=on \
    label.drawing=off \
    background.color=$MANTLE \
    background.height=24 \
    padding_left=3 \
    padding_right=3 \
    icon.padding_left=9 \
    icon.padding_right=9 \
    icon.highlight_color=$CRUST \
    icon.highlight=false \
    icon.color="$TEXT" \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/space_icon.sh $sid"
done
# #!/bin/bash
#
# sketchybar --add event aerospace_workspace_change
# CONFIG_DIR="$HOME/.config/sketchybar"
# source "$CONFIG_DIR/helpers/icon_map.sh"
# source "$CONFIG_DIR/colors.sh"
#
# # Array para guardar los nombres de los items
# space_items=()
#
# for sid in $(aerospace list-workspaces --all); do
#   sketchybar --add item space.$sid left \
#     --subscribe space.$sid aerospace_workspace_change \
#     --subscribe space.$sid front_app_switched \
#     --set space.$sid \
#     label="$sid" \
#     script="$CONFIG_DIR/plugins/space_icon.sh $sid" \
#     click_script="aerospace workspace $sid"
#
#   # Agregar al array
#   space_items+=("space.$sid")
# done
#
# CREAR el bracket con todos los items de workspace
#
# sketchybar --add event aerospace_workspace_change
#
# for sid in $(aerospace list-workspaces --all); do
#   sketchybar --add item space.$sid left \
#     --subscribe front_app front_app_switched \
#     --subscribe space.$sid aerospace_workspace_change \
#     --set space.$sid \
#       label="$sid" \
#       script="$CONFIG_DIR/plugins/space_icon.sh $sid" \
#       click_script="aerospace workspace $sid"
# done
