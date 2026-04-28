# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/battery.sh"

sketchybar --add item battery right \
  --set battery script="$PLUGIN" \
  update_freq=120 \
  updates=on \
  icon.color=$GOLD \
  label.color=$TEXT \
  icon.font="JetBrainsMono Nerd Font:Bold:16.0" \
  label.font="JetBrainsMono Nerd Font:Bold:13.0" \
  label.padding_right=8 \
  background.drawing=off
