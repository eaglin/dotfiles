# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/clock.sh"

sketchybar --add item clock right \
  --set clock script="$PLUGIN" \
  update_freq=10 \
  click_script="open -a Calendar" \
  padding_left=0 \
  icon.padding_left=20 \
  label.padding_right=20 \
  icon.color="$MAROON" \
  background.color=$SURFACE0 \
  background.border_color=$MAUVE \
  background.border_width=2 \
  background.corner_radius=6 \
  background.height=24
