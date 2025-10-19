# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/bluetooth_popup.sh"

sketchybar --add item bt right \
  --set bt script="$PLUGIN" \
  update_freq=10 \
  label.padding_left=4 \
  click_script="$PLUGIN" \
  popup.horizontal=off \
  popup.align=right \
  --subscribe bt mouse.clicked
