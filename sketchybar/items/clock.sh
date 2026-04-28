# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/clock.sh"

sketchybar --add item clock right \
  --set clock script="$PLUGIN" \
  update_freq=10 \
  icon.drawing=off \
  label.font="JetBrainsMono Nerd Font:Bold:13.0" \
  label.color=$TEXT \
  label.padding_right=10 \
  label.padding_left=20 \
  background.drawing=off
