# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/clock.sh"

sketchybar --add item clock right \
  --set clock script="$PLUGIN" \
  update_freq=10 \
  click_script="open -a Calendar" \
  icon.padding_left=10 \
  label.padding_right=10 \
  icon.color="$MAROON" \
  background.color=$SURFACE0 \
  background.border_color=$MAUVE \
  background.border_width=1 \
  background.corner_radius=6 \
  background.height=22
