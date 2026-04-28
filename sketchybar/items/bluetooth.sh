# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/bluetooth.sh"

sketchybar --add item bt right \
  --set bt script="$PLUGIN" \
  icon="󰂱" \
  icon.font="JetBrainsMono Nerd Font:Bold:17.0" \
  icon.color=$IRIS \
  label.drawing=off \
  label.font="JetBrainsMono Nerd Font:Bold:13.0" \
  label.color=$TEXT \
  background.drawing=off \
  update_freq=60 \
  click_script="$PLUGIN" \
  --subscribe bt mouse.clicked
