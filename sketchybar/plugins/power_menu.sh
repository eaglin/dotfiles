#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/power_menu.sh

source "$HOME/.config/sketchybar/colors.sh"

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
ICON="󰐥" # Nerd Font Power icon

populate_popup() {
  # Limpia el popup existente
  sketchybar --remove '/power\..*/'

  # Opción de Reposo
  sketchybar --add item power.sleep popup.power_menu \
    --set power.sleep \
    label="Reposo" \
    icon="󰒲" \
    icon.color=0xff8bd5ca \
    label.color=0xffcad3f5 \
    padding_left=10 \
    padding_right=10 \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.padding_left=10 \
    label.padding_right=15 \
    background.drawing=on \
    background.color=0x00000000 \
    background.height=24 \
    background.width=150 \
    background.corner_radius=6 \
    script="$PLUGIN_DIR/power_menu.sh" \
    click_script="pmset sleepnow; sketchybar --set power_menu popup.drawing=off" \
    --subscribe power.sleep mouse.entered mouse.exited

  # Opción de Reiniciar
  sketchybar --add item power.restart popup.power_menu \
    --set power.restart \
    label="Reiniciar" \
    icon="󰜉" \
    icon.color=0xfff5a97f \
    label.color=0xffcad3f5 \
    padding_left=10 \
    padding_right=10 \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.padding_left=10 \
    label.padding_right=15 \
    background.drawing=on \
    background.color=0x00000000 \
    background.height=24 \
    background.width=150 \
    background.corner_radius=6 \
    script="$PLUGIN_DIR/power_menu.sh" \
    click_script="osascript -e 'tell app \"System Events\" to restart'; sketchybar --set power_menu popup.drawing=off" \
    --subscribe power.restart mouse.entered mouse.exited

  # Opción de Apagar
  sketchybar --add item power.shutdown popup.power_menu \
    --set power.shutdown \
    label="Apagar" \
    icon="󰐥" \
    icon.color=0xffed8796 \
    label.color=0xffcad3f5 \
    padding_left=10 \
    padding_right=10 \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.padding_left=10 \
    label.padding_right=15 \
    background.drawing=on \
    background.color=0x00000000 \
    background.height=24 \
    background.width=150 \
    background.corner_radius=6 \
    script="$PLUGIN_DIR/power_menu.sh" \
    click_script="osascript -e 'tell app \"System Events\" to shut down'; sketchybar --set power_menu popup.drawing=off" \
    --subscribe power.shutdown mouse.entered mouse.exited
}

toggle_popup() {
  local popup_state=$(sketchybar --query power_menu | /usr/bin/jq -r '.popup.drawing')

  if [ "$popup_state" = "on" ]; then
    sketchybar --set power_menu popup.drawing=off
  else
    populate_popup
    sketchybar --set power_menu popup.drawing=on
  fi
}

case "${1:-$SENDER}" in
"mouse.clicked")
  toggle_popup
  ;;
"mouse.entered")
  # Determinar colores según el item
  case "$NAME" in
  "power.sleep")
    sketchybar --set "$NAME" background.color=0xff8bd5ca icon.color=0xff1e1e2e label.color=0xff1e1e2e
    ;;
  "power.restart")
    sketchybar --set "$NAME" background.color=0xfff5a97f icon.color=0xff1e1e2e label.color=0xff1e1e2e
    ;;
  "power.shutdown")
    sketchybar --set "$NAME" background.color=0xffed8796 icon.color=0xff1e1e2e label.color=0xff1e1e2e
    ;;
  esac
  ;;
"mouse.exited")
  # Restaurar colores originales
  case "$NAME" in
  "power.sleep")
    sketchybar --set "$NAME" background.color=0x00000000 icon.color=0xff8bd5ca label.color=0xffcad3f5
    ;;
  "power.restart")
    sketchybar --set "$NAME" background.color=0x00000000 icon.color=0xfff5a97f label.color=0xffcad3f5
    ;;
  "power.shutdown")
    sketchybar --set "$NAME" background.color=0x00000000 icon.color=0xffed8796 label.color=0xffcad3f5
    ;;
  esac
  ;;
*)
  # Inicializar el icono
  sketchybar --set power_menu icon="$ICON" icon.color=0xffed8796
  ;;
esac
